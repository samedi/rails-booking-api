# frozen_string_literal: true

# Fetches details about an institution.
class FetchInstitutionDetails
  APIError = Class.new(StandardError)
  InstitutionNotFound = Class.new(APIError)

  def initialize(connection_provider: ServiceContainer.booking_connection_provider)
    @connection = connection_provider.connection
  end

  # Gets an institution given its ID.
  #
  # The only data it returns is the institution name. All other attributes of the returned
  # {Institution} will be `nil`.
  # @param institution_id [String] Hashed ID of the institution for which the name should be
  #   retrieved.
  # @return [Institution] A single institution instance with name set.
  def call(institution_id:)
    response = @connection.get("practices/#{institution_id}")

    if response.success?
      parse_response_body(response.body, institution_id)
    elsif response.status == 404
      raise InstitutionNotFound
    else
      raise APIError, "Received status #{response.status}"
    end
  end

  private

  def parse_response_body(body, institution_id)
    Institution.new(
      id: institution_id,
      name: body.fetch('name')
    )
  end
end
