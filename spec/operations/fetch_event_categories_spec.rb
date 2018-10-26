# frozen_string_literal: true

require 'json'
require 'faraday'
require 'faraday_middleware'
require 'samedi'
require 'samedi/patient_api'
require 'samedi/patient_api/connection_provider'
require 'institution'
require 'event_category'
require 'fetch_event_categories'
require 'test_service_container'

RSpec.describe FetchEventCategories do
  describe '#call' do
    it 'returns a list of categories', vcr: { cassette_name: 'fetch_event_categories_success' } do
      institution = Institution.new(id: 'BCMNWE2W3N2R3Z4K', name: 'Krankenkasse VM')
      subject = described_class.new(connection_provider: TestServiceContainer.booking_connection_provider)

      result = subject.call(institution: institution)

      expect(result).to be_any.and all(be_an(EventCategory))
    end

    it 'raises InstitutionNotFound exception when institution_id does not exist', vcr: { cassette_name: 'fetch_event_categories_404' } do
      institution = Institution.new(id: '404_Institution_Not_Found', name: 'Institution Not Found')
      subject = described_class.new(connection_provider: TestServiceContainer.booking_connection_provider)

      expect {
        subject.call(institution: institution)
      }.to raise_error(FetchEventCategories::InstitutionNotFound)
    end
  end

  describe '#find_single' do
    it 'returns a single category by its ID', vcr: { cassette_name: 'fetch_event_categories_success' } do
      institution = Institution.new(id: 'BCMNWE2W3N2R3Z4K', name: 'Krankenkasse VM')
      event_category_id = 11_102
      subject = described_class.new(connection_provider: TestServiceContainer.booking_connection_provider)

      result = subject.find_single(institution: institution, event_category_id: event_category_id)

      expect(result.id).to eq(event_category_id)
      expect(result.name).to eq('Dr. Peter')
    end

    it 'returns a single category by its ID when given as string', vcr: { cassette_name: 'fetch_event_categories_success' } do
      institution = Institution.new(id: 'BCMNWE2W3N2R3Z4K', name: 'Krankenkasse VM')
      event_category_id = '11102'
      subject = described_class.new(connection_provider: TestServiceContainer.booking_connection_provider)

      result = subject.find_single(institution: institution, event_category_id: event_category_id)

      expect(result.id).to eq(event_category_id.to_i)
      expect(result.name).to eq('Dr. Peter')
    end

    it 'raises EventCategoryNotFound when the institution does not have a category with the requested ID', vcr: { cassette_name: 'fetch_event_categories_success' } do
      institution = Institution.new(id: 'BCMNWE2W3N2R3Z4K', name: 'Krankenkasse VM')
      event_category_id = 42
      subject = described_class.new(connection_provider: TestServiceContainer.booking_connection_provider)

      expect {
        subject.find_single(institution: institution, event_category_id: event_category_id)
      }.to raise_error(FetchEventCategories::EventCategoryNotFound)
    end
  end
end
