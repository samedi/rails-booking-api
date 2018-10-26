# frozen_string_literal: true

require 'json'
require 'faraday'
require 'faraday_middleware'
require 'time'
require 'samedi'
require 'samedi/patient_api'
require 'samedi/patient_api/connection_provider'
require 'institution'
require 'event_category'
require 'event_type'
require 'timeslot'
require 'fetch_timeslots'
require 'test_service_container'

RSpec.describe FetchTimeslots do
  # TODO: mock these specs
  # I'm very skeptical about these specs - if there are no free timeslots, an empty
  # array will be returned and the expectations will fail. These are all time-dependent
  # flaky specs. The code needs to be refactored to allow proper mocking so the test
  # can be useful.
  describe '#call' do
    let(:today) { Date.new(2018, 10, 29) }

    it 'returns a list of timeslots for today', vcr: { cassette_name: 'fetch_timeslots_today' } do
      institution = Institution.new(id: '00JDFP8A3KYME1FA', name: 'Praxis Zweig (DEMO)')
      event_category = EventCategory.new(id: 50_409, institution: institution, name: 'Termin für Online-Videosprechstunde')
      event_type = EventType.new(id: 156_481, institution: institution, event_category: event_category, name: 'Sprechstunde')
      subject = described_class.new(connection_provider: TestServiceContainer.booking_connection_provider)

      result = subject.call(event_type: event_type)

      times = result.map(&:time)
      dates = times.map { |d| d.strftime('%Y-%m-%d') }

      expect(dates.uniq).to eq [today.to_s]
    end

    it 'returns a list of timeslots for the specified day', vcr: { cassette_name: 'fetch_timeslots_date' } do
      next_monday = today - today.wday + 8 # Date#wday returns 0 for Sunday
      institution = Institution.new(id: '00JDFP8A3KYME1FA', name: 'Praxis Zweig (DEMO)')
      event_category = EventCategory.new(id: 50_409, institution: institution, name: 'Termin für Online-Videosprechstunde')
      event_type = EventType.new(id: 156_481, institution: institution, event_category: event_category, name: 'Sprechstunde')
      subject = described_class.new(connection_provider: TestServiceContainer.booking_connection_provider)

      result = subject.call(
        event_type: event_type,
        date: next_monday
      )

      times = result.map(&:time)
      dates = times.map { |d| d.strftime('%Y-%m-%d') }

      expect(dates.uniq).to eq [next_monday.to_s]
    end

    it 'returns a list of timeslots for all days between two specified days', vcr: { cassette_name: 'fetch_timeslots_date_range' } do
      next_monday = today - today.wday + 8 # Date#wday returns 0 for Sunday
      next_friyay = next_monday + 4
      institution = Institution.new(id: '00JDFP8A3KYME1FA', name: 'Praxis Zweig (DEMO)')
      event_category = EventCategory.new(id: 50_409, institution: institution, name: 'Termin für Online-Videosprechstunde')
      event_type = EventType.new(id: 156_481, institution: institution, event_category: event_category, name: 'Sprechstunde')
      subject = described_class.new(connection_provider: TestServiceContainer.booking_connection_provider)

      result = subject.call(
        event_type: event_type,
        from_date: next_monday,
        to_date: next_friyay
      )

      times = result.map(&:time)
      dates = times.map { |d| d.strftime('%Y-%m-%d') }

      expect(dates.uniq).to satisfy('cover 5 days') { |v| v.size == 5 }
    end

    it 'raises EventTypeOrCategoryNotFound exception when event_category_id does not exist', vcr: { cassette_name: 'fetch_timeslots_404' } do
      institution = Institution.new(id: '00JDFP8A3KYME1FA', name: 'Praxis Zweig (DEMO)')
      event_category = EventCategory.new(id: 2**64 - 1, institution: institution, name: 'Unknown')
      event_type = EventType.new(id: 2**64 - 1, institution: institution, event_category: event_category, name: 'Unknown')
      subject = described_class.new(connection_provider: TestServiceContainer.booking_connection_provider)

      expect {
        subject.call(event_type: event_type)
      }.to raise_error(FetchTimeslots::EventTypeOrCategoryNotFound)
    end
  end
end
