# frozen_string_literal: true

# Fetches timesots that can potentially be booked.
class FetchTimeslots
  APIError = Class.new(StandardError)
  EventTypeOrCategoryNotFound = Class.new(APIError)
  ForbiddenWithCurrentInsuranceSettings = Class.new(APIError)

  def initialize(connection_provider: ServiceContainer.booking_connection_provider)
    @connection = connection_provider.non_caching_connection
  end

  # Finds possible timeslots for booking by the given event category and type for the given date or date range.
  #
  # The date range can be specified in a few ways:
  #
  # * when `date` is set to `:today` (default value), the timeslots for the current day are returned
  # * when `date` is set to a `Date`, the available timeslots are returned
  # * when `from_date` and `to_date` are set to `Date` objects, all available timeslots between the two dates
  #   are returned.
  #
  # @param event_type [EventType] Event type for which timeslots should be fetched.
  # @param date [:today, Date] `:today` will request all timeslots for the current day.
  #   If a `Date` is given, all timeslots for the specified day will be returned.
  # @param from_date [Date] Beginning of the range. This will request all timeslots starting with the specified day.
  # @param to_date [Date] End of the range. This will request all timeslots ending with the specified date.
  # @return [Array<Timeslot>] List of timeslots.
  def call(event_type:, date: :today, from_date: nil, to_date: nil)
    response = @connection.get('times') { |request|
      request.params.merge!(request_params(event_type: event_type, date: date, from_date: from_date, to_date: to_date))
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

  def request_params(event_type:, date:, from_date:, to_date:)
    params = {}

    params[:event_category_id] = event_type.event_category.id
    params[:event_type_id] = event_type.id

    if from_date && to_date
      params[:from] = from_date.to_s
      params[:to] = to_date.to_s
    elsif date != :today
      params[:date] = date.to_s
    end

    params
  end

  def parse_response_body(body, event_type)
    plain_data = body.fetch('data')

    plain_data.map { |h|
      Timeslot.new(
        institution: event_type.institution,
        event_category: event_type.event_category,
        event_type: event_type,
        time: h.fetch('time'),
        token: h.fetch('token')
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
end
