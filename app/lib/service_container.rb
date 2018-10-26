# frozen_string_literal: true

# Container for various services used by the app.
module ServiceContainer
  module_function

  def client_id
    ENV.fetch('CLIENT_ID')
  end

  def fetch_institution_details
    @fetch_institution_details ||= FetchInstitutionDetails.new
  end

  def fetch_event_categories
    @fetch_event_categories ||= FetchEventCategories.new
  end

  def fetch_event_types
    @fetch_event_types ||= FetchEventTypes.new
  end

  def booking_connection_provider
    @booking_connection_provider ||= Samedi::PatientAPI::ConnectionProvider.new(
      client_id: client_id,
      cache_store: booking_cache_store
    )
  end

  def event_type_api_mapper
    @event_type_api_mapper ||= EventTypeAPIMapper.new
  end

  def booking_cache_store
    @booking_cache_store ||= ActiveSupport::Cache::FileStore.new(
      cache_dir,
      namespace: 'booking_api',
      expires_in: 20.minutes
    )
  end

  def cache_dir
    @cache_dir ||= File.join(ENV['TMPDIR'] || '/tmp', 'cache')
  end
end
