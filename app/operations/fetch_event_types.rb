# frozen_string_literal: true

# Fetches event types for a given event category.
class FetchEventTypes
  APIError = Class.new(StandardError)
  EventTypeOrCategoryNotFound = Class.new(APIError)

  attr_reader :event_type_mapper

  def initialize(
    connection_provider: ServiceContainer.booking_connection_provider,
    event_type_mapper: ServiceContainer.event_type_api_mapper
  )
    @connection = connection_provider.connection
    @event_type_mapper = event_type_mapper
  end

  # Finds event types for a given category.
  # @param event_category [EventCategory] event category for which types should be retrieved.
  # @return [Array<EventType>] List of event type entities for the given category.
  # @raise [EventTypeOrCategoryNotFound] when a category with the given ID doesn't exist.
  def call(event_category:)
    response = @connection.get('event_types') { |request|
      request.params[:event_category_id] = event_category.id
    }

    if response.success?
      parse_response_body(response.body, event_category)
    else
      handle_errors(response)
    end
  rescue Faraday::TimeoutError
    raise APIError, 'Connection timed out'
  end

  # Finds a single event type belonging to a given category.
  #
  # This is just a helper that filters out a single EventType from the collection returned by {#call}.
  #
  # @param event_category [EventCategory] Event category for which a type should be retrieved.
  # @param event_type_id [Integer] ID of the requested event type.
  # @return [EventType] Event type entity with the specified ID.
  # @raise [EventTypeOrCategoryNotFound] when a category with the given ID doesn't exist or when an event type
  #   with the given ID can't be found for the given category.
  def find_single(event_category:, event_type_id:)
    call(event_category: event_category)
      .find(
        -> { raise EventTypeOrCategoryNotFound, "EventType #{event_type_id} not found" }
      ) { |et|
        et.id == event_type_id.to_i
      }
  end

  private

  def parse_response_body(body, event_category)
    event_type_mapper.map_collection(body.fetch('data'), event_category: event_category)
  end

  def handle_errors(response)
    case response.status
    when 404 then raise EventTypeOrCategoryNotFound
    else raise APIError, "Received status #{response.status}"
    end
  end
end
