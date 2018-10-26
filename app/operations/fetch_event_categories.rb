# frozen_string_literal: true

# Fetches event categories for a given institution.
class FetchEventCategories
  APIError = Class.new(StandardError)
  InstitutionNotFound = Class.new(APIError)
  EventCategoryNotFound = Class.new(APIError)

  def initialize(connection_provider: ServiceContainer.booking_connection_provider)
    @connection = connection_provider.connection
  end

  # Finds event categories for a given institution.
  # @param institution [Institution] institution for which categories should be retrieved
  # @return [Array<EventCategory>] List of event category entities for the given institution
  def call(institution:)
    response = @connection.get('event_categories') { |request|
      request.params[:practice_id] = institution.id
    }

    if response.success?
      parse_response_body(response.body, institution)
    else
      handle_errors(response)
    end
  rescue Faraday::TimeoutError
    raise APIError, 'Connection timed out'
  end

  # Finds a single event category belonging to a given institution.
  #
  # This is just a helper that filters out a single EventCategory from the collection returned by {#call}.
  #
  # @param institution [Institution] Institution for which categories should be retrieved.
  # @param event_category_id [Integer] ID of the requested category.
  # @return [EventCategory] Event category with the requested ID.
  # @raise [EventCategoryNotFound] when a category with the given ID cannot be found for the given institution.
  def find_single(institution:, event_category_id:)
    event_category_id = event_category_id.to_i

    call(institution: institution)
      .find(
        -> { raise EventCategoryNotFound, "EventCategory #{event_category_id} not found" }
      ) { |event_category|
        event_category.id == event_category_id
      }
  end

  private

  def parse_response_body(body, institution) # rubocop:disable Metrics/MethodLength
    plain_data = body.fetch('data')

    plain_data.map { |h|
      EventCategory.new(
        id: h.fetch('id'),
        institution: institution,
        name: h.fetch('name'),
        description: h.fetch('description'),
        subtitle: h.fetch('subtitle'),
        photo_url: h.fetch('photo_url')
      )
    }
  end

  def handle_errors(response)
    case response.status
    when 404 then raise InstitutionNotFound
    else raise APIError, "Received status #{response.status}"
    end
  end
end
