# frozen_string_literal: true

require 'json'
require 'faraday'
require 'faraday_middleware'
require 'samedi'
require 'samedi/patient_api'
require 'samedi/patient_api/connection_provider'
require 'institution'
require 'event_category'
require 'fetch_event_types'
require 'test_service_container'

RSpec.describe FetchEventTypes do
  describe '#call' do
    it 'returns mapped response', vcr: { cassette_name: 'fetch_event_types_success' } do
      institution = Institution.new(id: 'BCMNWE2W3N2R3Z4K', name: 'Krankenkasse VM')
      event_category = EventCategory.new(id: 50_409, institution: institution, name: 'Dr. Peter')
      mapper = instance_spy('EventTypeAPIMapper')
      subject = described_class.new(connection_provider: TestServiceContainer.booking_connection_provider, event_type_mapper: mapper)

      subject.call(event_category: event_category)

      expect(mapper).to have_received(:map_collection).with(
        a_collection_containing_exactly(hash_including('id' => 156_481)),
        event_category: event_category
      )
    end

    it 'raises EventTypeOrCategoryNotFound exception when event category ID does not exist', vcr: { cassette_name: 'fetch_event_types_404' } do
      institution = Institution.new(id: 'BCMNWE2W3N2R3Z4K', name: 'Krankenkasse VM')
      event_category = EventCategory.new(id: 2**64 - 1, institution: institution, name: 'Unknown')
      mapper = instance_double('EventTypeAPIMapper')
      subject = described_class.new(connection_provider: TestServiceContainer.booking_connection_provider, event_type_mapper: mapper)

      expect {
        subject.call(event_category: event_category)
      }.to raise_error(described_class::EventTypeOrCategoryNotFound)
    end
  end

  describe '#find_single' do
    it 'returns a single event type, filtered from the collection', vcr: { cassette_name: 'fetch_event_types_success' } do
      institution = Institution.new(id: 'BCMNWE2W3N2R3Z4K', name: 'Krankenkasse VM')
      event_category = EventCategory.new(id: 50_409, institution: institution, name: 'Dr. Peter')
      event_type_id = 42
      event_types = [instance_double('EventType', id: 1337), instance_double('EventType', id: 42)]
      mapper = instance_double('EventTypeAPIMapper', map_collection: event_types)
      subject = described_class.new(connection_provider: TestServiceContainer.booking_connection_provider, event_type_mapper: mapper)

      result = subject.find_single(event_category: event_category, event_type_id: event_type_id)

      expect(result.id).to eq(42)
    end

    it 'returns a single event type, filtered from the collection even when given a string', vcr: { cassette_name: 'fetch_event_types_success' } do
      institution = Institution.new(id: 'BCMNWE2W3N2R3Z4K', name: 'Krankenkasse VM')
      event_category = EventCategory.new(id: 50_409, institution: institution, name: 'Dr. Peter')
      event_type_id = '42'
      event_types = [instance_double('EventType', id: 1337), instance_double('EventType', id: 42)]
      mapper = instance_double('EventTypeAPIMapper', map_collection: event_types)
      subject = described_class.new(connection_provider: TestServiceContainer.booking_connection_provider, event_type_mapper: mapper)

      result = subject.find_single(event_category: event_category, event_type_id: event_type_id)

      expect(result.id).to eq(42)
    end

    it 'raises EventTypeOrCategoryNotFound exception when the event_category_id does not exist', vcr: { cassette_name: 'fetch_event_types_404' } do
      institution = Institution.new(id: 'BCMNWE2W3N2R3Z4K', name: 'Krankenkasse VM')
      event_category = EventCategory.new(id: 2**64 - 1, institution: institution, name: 'Unknow')
      event_type_id = 42
      event_types = [instance_double('EventType', id: 1337), instance_double('EventType', id: 42)]
      mapper = instance_double('EventTypeAPIMapper', map_collection: event_types)
      subject = described_class.new(connection_provider: TestServiceContainer.booking_connection_provider, event_type_mapper: mapper)

      expect {
        subject.find_single(event_category: event_category, event_type_id: event_type_id)
      }.to raise_error(described_class::EventTypeOrCategoryNotFound)
    end

    it 'raises EventTypeOrCategoryNotFound exception when the event type cannot be found within the category', vcr: { cassette_name: 'fetch_event_types_success' } do
      institution = Institution.new(id: 'BCMNWE2W3N2R3Z4K', name: 'Krankenkasse VM')
      event_category = EventCategory.new(id: 50_409, institution: institution, name: 'Dr. Peter')
      event_type_id = 43
      event_types = [instance_double('EventType', id: 1337), instance_double('EventType', id: 42)]
      mapper = instance_double('EventTypeAPIMapper', map_collection: event_types)
      subject = described_class.new(connection_provider: TestServiceContainer.booking_connection_provider, event_type_mapper: mapper)

      expect {
        subject.find_single(event_category: event_category, event_type_id: event_type_id)
      }.to raise_error(described_class::EventTypeOrCategoryNotFound)
    end
  end
end
