# frozen_string_literal: true

module TestServiceContainer
  class NullCacheStore
    def read(*)
      nil
    end

    def write(*)
      nil
    end

    def fetch(*)
      yield
    end
  end

  module_function

  def booking_connection_provider
    Samedi::PatientAPI::ConnectionProvider.new(client_id: ENV.fetch('CLIENT_ID'), cache_store: null_cache_store)
  end

  def null_cache_store
    NullCacheStore.new
  end
end
