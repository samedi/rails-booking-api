# frozen_string_literal: true

# Fetches days for a given event category and type for a given month.
class FetchEventDates
  FIND_AVAILABLE_MONTH_LIMIT = 6
  APIError = Class.new(StandardError)
  EventTypeOrCategoryNotFound = Class.new(APIError)
  ForbiddenWithCurrentInsuranceSettings = Class.new(APIError)

  def initialize(connection_provider: ServiceContainer.booking_connection_provider, reference_date: Date.today)
    @connection = connection_provider.non_caching_connection
    @reference_date = reference_date
  end

  # Finds possible dates for booking by the given event type in the given date range.
  #
  # @param event_type [EventType] Event type for which dates should be looked up.
  # @param range [:current, :find_available, Date, Range<Date>]
  #   * `:current` will request all dates for the current month.
  #   * `:find_available` will request the number of months in future as specified by {FIND_AVAILABLE_MONTH_LIMIT}.
  #   * If a `Date` is given, all dates for the specified year and month will be given.
  #   * If a `Range` is given, all dates in the months specified by the range will be given.
  # @return [Array<EventDates>] List of event dates.
  def call(event_type:, range: :current)
    response = @connection.get('dates') { |request|
      request.params.merge!(request_params(event_type: event_type, range: range))
    }

    if response.success?
      parse_response_body(response.body, event_type)
    else
      handle_errors(response)
    end
  rescue Faraday::TimeoutError
    raise APIError, 'Connection timed out'
  end

  private

  def request_params(event_type:, range:)
    params = {}

    params[:event_category_id] = event_type.event_category.id
    params[:event_type_id] = event_type.id

    range_params = range_to_params(range)
    params.merge!(range_params) if range_params

    params
  end

  def parse_response_body(body, event_type)
    plain_data = body.fetch('data')

    plain_data.map { |h|
      EventDate.new(
        institution: event_type.institution,
        event_category: event_type.event_category,
        event_type: event_type,
        date: h.fetch('date'),
        available: h.fetch('available')
      )
    }
  end

  def handle_errors(response)
    case response.status
    when 403 then raise ForbiddenWithCurrentInsuranceSettings
    when 404 then raise EventTypeOrCategoryNotFound
    else raise APIError, "Received status #{response.status}"
    end
  end

  def range_to_params(range)
    case range
    when :find_available
      from_month, to_month = build_range_from(@reference_date, months: FIND_AVAILABLE_MONTH_LIMIT)
      { from: from_month, to: to_month }
    when Date
      { date: range.to_date.to_s }
    when Range
      { from: range.first.to_date.to_s, to: range.last.to_date.to_s }
    end
  end

  def build_range_from(date, months:)
    # We don't use ActiveSupport in this part of the code, so there's no `+ 6.months` magic
    months_after_today = date.month + (months - 1)
    year_diff, month = months_after_today.divmod(12)

    [date.to_s, Date.new(date.year + year_diff, month, 1).to_s]
  end
end
