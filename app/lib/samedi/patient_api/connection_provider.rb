# frozen_string_literal: true

module Samedi
  module PatientAPI
    # Provides a connection to samedi Booking API.
    class ConnectionProvider
      TIMEOUT = 5 # seconds

      # Gets the connection to Samedi Booking API.
      # @return [Faraday::Connection] A Faraday connection configured for samedi Booking API.
      attr_reader :connection

      # Gets the connection to Samedi Booking API that doesn't cache responses.
      # @return [Faraday::Connection] A Faraday connection configured for samedi Booking API with no caching.
      attr_reader :non_caching_connection

      # Sets up a connection to samedi Booking API.
      # @param client_id [String] Client ID needed for every request to the API.
      def initialize(client_id:, cache_store:)
        @client_id = client_id

        @non_caching_connection = build_connection

        @connection = build_connection { |faraday|
          faraday.response :caching, ignore_params: %w[client_id] do
            cache_store
          end
        }
      end

      private

      def build_connection
        Faraday.new { |faraday|
          faraday.url_prefix = 'https://patient.samedi.de/api/booking/v3'
          faraday.params = { client_id: @client_id }
          faraday.options.timeout = TIMEOUT

          faraday.response :json
          yield faraday if block_given?

          faraday.adapter :typhoeus
        }
      end
    end
  end
end
