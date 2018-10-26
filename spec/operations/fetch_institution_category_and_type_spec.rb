# frozen_string_literal: true

require 'json'
require 'faraday'
require 'faraday_middleware'
require 'fetch_institution_category_and_type'

RSpec.describe FetchInstitutionCategoryAndType do
  describe '#call' do
    it 'fetches institution, event category, and event type' do
      institution = instance_double('Institution')
      event_category = instance_double('EventCategory')
      event_type = instance_double('EventType')
      fetch_institution_details = instance_double('FetchInstitutionDetails', call: institution)
      fetch_event_categories = instance_double('FetchEventCategories', find_single: event_category)
      fetch_event_types = instance_double('FetchEventTypes', find_single: event_type)
      subject = described_class.new(
        fetch_institution_details: fetch_institution_details,
        fetch_event_categories: fetch_event_categories,
        fetch_event_types: fetch_event_types
      )

      result = subject.call(institution_id: 12, event_category_id: 24, event_type_id: 36)

      expect(result).to eq([institution, event_category, event_type])
    end

    it 'passes the correct IDs to compsoed objects' do
      institution_id = 12
      event_category_id = 24
      event_type_id = 36
      institution = instance_double('Institution')
      event_category = instance_double('EventCategory')
      fetch_institution_details = instance_double('FetchInstitutionDetails')
      allow(fetch_institution_details).to receive(:call)
        .with(institution_id: institution_id)
        .and_return(institution)
      fetch_event_categories = instance_spy('FetchEventCategories')
      allow(fetch_event_categories).to receive(:find_single)
        .with(institution: institution, event_category_id: event_category_id)
        .and_return(event_category)
      fetch_event_types = instance_spy('FetchEventTypes')
      subject = described_class.new(
        fetch_institution_details: fetch_institution_details,
        fetch_event_categories: fetch_event_categories,
        fetch_event_types: fetch_event_types
      )

      subject.call(institution_id: 12, event_category_id: 24, event_type_id: 36)

      expect(fetch_event_types).to have_received(:find_single)
        .with(event_category: event_category, event_type_id: event_type_id)
    end
  end
end
