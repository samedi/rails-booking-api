# frozen_string_literal: true

# Books an event on behalf of a patient
class BookEvent
  APIError = Class.new(StandardError)
  EventUnavailable = Class.new(APIError)
  EventTypeOrCategoryNotFound = Class.new(APIError)
  ForbiddenWithCurrentInsuranceSettings = Class.new(APIError)

  # Wraps validation errors returned by the API server.
  class CommentFormValidationError < APIError
    # @return [Hash<String, String>] a hash with validation errors as they are returned by API.
    attr_reader :errors

    def initialize(errors)
      super
      @errors = errors
    end
  end

  def initialize(connection_provider: ServiceContainer.booking_connection_provider)
    @connection = connection_provider.non_caching_connection
  end

  # Books an event on behalf of the patient
  #
  # @param patient [Patient] A patient for which the event is being booked.
  # @param timeslot [Timeslot] An event being booked represented by the timeslot object.
  # @param structured_comment [Hash] A hash containing structured comment data dictated by an event type.
  # @return [BookingConfirmation] Details of the performed booking.
  # @raise [EventUnavailable] In case the booking was not possible because the time slot
  #   has already been used (or was not valid).
  # @raise [CommentFormValidationError] In case the event type requires the structured form, and the values
  #   didn't satisfy validation by the API.
  # @raise [EventTypeOrCategoryNotFound] In case the event category or event type could not
  #   be found.
  # @raise [APIError] In case of a different error returned by samedi Booking API.
  def call(patient:, timeslot:, structured_comment: nil)
    response = book(
      patient: patient, timeslot: timeslot, structured_comment: structured_comment
    )

    if response.success?
      parse_response_body(response.body)
    else
      handle_errors(response)
    end
  end

  private

  def book(patient:, **args)
    @connection.post('book') do |request|
      request.headers['Authorization'] = "Bearer #{patient.access_token}"
      request.body = request_body(**args)
    end
  rescue Faraday::TimeoutError
    raise APIError, 'Connection timed out'
  end

  def parse_response_body(body)
    plain_data = body.fetch('data')

    BookingConfirmation.new(id: plain_data.fetch('id'))
  end

  def handle_errors(response)
    case response.status
    when 400 then handle_400_error(response.body)
    when 403 then raise ForbiddenWithCurrentInsuranceSettings
    when 404 then raise EventTypeOrCategoryNotFound
    when 422 then handle_422_error(response.body)
    else raise APIError, "Received status #{response.status}"
    end
  end

  def request_body(timeslot:, structured_comment:)
    body = {
      event_category_id: timeslot.event_category.id,
      event_type_id: timeslot.event_type.id,
      starts_at: timeslot.time.iso8601,
      token: timeslot.token
    }
    body[:structured_comment] = structured_comment if structured_comment

    body
  end

  def handle_400_error(body)
    error = body.fetch('error') { body.fetch('reason') { raise APIError, 'Unknown 400 error' } }

    case error
    when 'The event is unavailable.'
      raise EventUnavailable, error
    when 'attendant_blocked'
      raise APIError, "Attendant blocked. Overridable: #{body.fetch('overridable')}"
    else
      raise APIError, error
    end
  end

  def handle_422_error(body)
    reason = body.fetch('reason') { raise APIError, 'Unknown 422 error' }
    errors = body.fetch('invalid_fields') { raise APIError, 'Unknown 422 error' }

    raise CommentFormValidationError.new(errors), reason
  end
end
