# frozen_string_literal: true

module OmniAuth
  module Strategies
    # Provides implementation of an OmniAuth strategy that works with samedi Booking API.
    #
    # For more information, consult the OmniAuth Strategy Contribution Guide:
    # https://github.com/omniauth/omniauth/wiki/Strategy-Contribution-Guide
    #
    # Note: this file is explicitly required by config/initializers/omniauth.rb so changes to it
    # won't be automatically reloaded and you need to restart the Rails app after every change to the strategy.
    # Changing `require` to `require_dependency` won't work, because Rails doesn't clear dependencies
    # required by initializers.
    class Samedi
      include OmniAuth::Strategy

      args %i[client_id client_secret]

      option :client_id, nil
      option :client_secret, nil
      option :samedi_booking_api_url_prefix, 'https://patient.samedi.de/api/auth/v2'
      option :response_type, 'code'
      option :grant_type, 'authorization_code'

      credentials do
        @credentials
      end

      def request_phase
        query_params = {
          response_type: options.response_type,
          client_id: options.client_id,
          redirect_uri: CGI.escape(callback_url)
        }

        query_string = query_params.map { |k, v| "#{k}=#{v}" }.join('&')

        redirect "#{options.samedi_booking_api_url_prefix}/authorize?#{query_string}"
      end

      def callback_phase
        code = request.params.fetch('code') { fail! 'Missing required parameter "code"' }

        response = post_token_request(code)
        response_hash = JSON.parse(response.body)

        fail! response_hash.values_at('error', 'error_description').join(': ') if response_hash.key?('error')

        @credentials = response_hash

        super
      end

      private

      def post_token_request(code)
        token_request_connection.post(
          'token',
          grant_type: options.grant_type,
          client_id: options.client_id,
          client_secret: options.client_secret,
          code: code,
          redirect_uri: callback_url.gsub(/\?.*/, '')
        )
      end

      def token_request_connection
        @token_request_connection ||= Faraday.new(options.samedi_booking_api_url_prefix) do |faraday|
          faraday.request  :url_encoded
          faraday.response :logger
          faraday.adapter  Faraday.default_adapter
        end
      end
    end
  end
end
