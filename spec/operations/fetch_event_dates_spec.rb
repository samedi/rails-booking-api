# frozen_string_literal: true

require 'json'
require 'faraday'
require 'faraday_middleware'
require 'date'
require 'samedi'
require 'samedi/patient_api'
require 'samedi/patient_api/connection_provider'
require 'institution'
require 'event_category'
require 'event_type'
require 'event_date'
require 'fetch_event_dates'
require 'test_service_container'

RSpec.describe FetchEventDates do
  describe '#call' do
    let(:today) { Date.new(2018, 10, 26) }

    it 'returns a list of dates for the current month and 1st of the next month', vcr: { cassette_name: 'fetch_event_dates_today' } do
      institution = Institution.new(id: '00JDFP8A3KYME1FA', name: 'Praxis Zweig (DEMO)')
      event_category = EventCategory.new(id: 50_409, institution: institution, name: 'Termin für Online-Videosprechstunde')
      event_type = EventType.new(id: 156_481, institution: institution, event_category: event_category, name: 'Sprechstunde')
      subject = described_class.new(connection_provider: TestServiceContainer.booking_connection_provider)

      result = subject.call(event_type: event_type)

      dates = result.map(&:date)
      all_but_last_dates = dates[0...-1]
      year_and_months = all_but_last_dates.map { |d| d.strftime('%Y-%m') }

      expect(year_and_months).to all(eq today.strftime('%Y-%m'))
    end

    it 'returns a list of dates for the next six monhts when given `:find_available`', vcr: { cassette_name: 'fetch_event_dates_find_available' } do
      institution = Institution.new(id: '00JDFP8A3KYME1FA', name: 'Praxis Zweig (DEMO)')
      event_category = EventCategory.new(id: 50_409, institution: institution, name: 'Termin für Online-Videosprechstunde')
      event_type = EventType.new(id: 156_481, institution: institution, event_category: event_category, name: 'Sprechstunde')
      subject = described_class.new(connection_provider: TestServiceContainer.booking_connection_provider, reference_date: today)

      result = subject.call(
        event_type: event_type,
        range: :find_available
      )

      dates = result.map(&:date)
      all_but_last_dates = dates[0...-1]
      unique_year_and_months = all_but_last_dates.map { |d| d.strftime('%Y-%m') }.uniq

      expect(unique_year_and_months).to satisfy('cover 6 or 7 months') { |v| (6..7).cover?(v.size) }
    end

    it 'returns a list of dates for the specified month and 1st of the next month', vcr: { cassette_name: 'fetch_event_dates_month' } do
      two_months_from_now = today + (2 * 31)
      institution = Institution.new(id: '00JDFP8A3KYME1FA', name: 'Praxis Zweig (DEMO)')
      event_category = EventCategory.new(id: 50_409, institution: institution, name: 'Termin für Online-Videosprechstunde')
      event_type = EventType.new(id: 156_481, institution: institution, event_category: event_category, name: 'Sprechstunde')
      subject = described_class.new(connection_provider: TestServiceContainer.booking_connection_provider)

      result = subject.call(
        event_type: event_type,
        range: two_months_from_now
      )

      dates = result.map(&:date)
      all_but_last_dates = dates[0...-1]
      year_and_months = all_but_last_dates.map { |d| d.strftime('%Y-%m') }

      expect(year_and_months).to all(eq two_months_from_now.strftime('%Y-%m'))
    end

    it 'returns a list of dates for all days between specified monhs + 1 extra day for the subsequent month', vcr: { cassette_name: 'fetch_event_dates_date_range' } do
      two_months_from_now = today + (2 * 31)
      four_months_from_now = today + (4 * 31)
      institution = Institution.new(id: '00JDFP8A3KYME1FA', name: 'Praxis Zweig (DEMO)')
      event_category = EventCategory.new(id: 50_409, institution: institution, name: 'Termin für Online-Videosprechstunde')
      event_type = EventType.new(id: 156_481, institution: institution, event_category: event_category, name: 'Sprechstunde')
      subject = described_class.new(connection_provider: TestServiceContainer.booking_connection_provider)

      result = subject.call(
        event_type: event_type,
        range: two_months_from_now..four_months_from_now
      )

      dates = result.map(&:date)
      all_but_last_dates = dates[0...-1]
      unique_year_and_months = all_but_last_dates.map { |d| d.strftime('%Y-%m') }.uniq

      expect(unique_year_and_months).to satisfy('cover 3 or 4 months') { |v| (3..4).cover?(v.size) }
    end

    it 'raises EventTypeOrCategoryNotFound exception when event_category_id does not exist', vcr: { cassette_name: 'fetch_event_dates_404' } do
      institution = Institution.new(id: '00JDFP8A3KYME1FA', name: 'Praxis Zweig (DEMO)')
      event_category = EventCategory.new(id: 2**64 - 1, institution: institution, name: 'Termin für Online-Videosprechstunde')
      event_type = EventType.new(id: 2**64 - 1, institution: institution, event_category: event_category, name: 'Sprechstunde')
      subject = described_class.new(connection_provider: TestServiceContainer.booking_connection_provider)

      expect {
        subject.call(event_type: event_type)
      }.to raise_error(FetchEventDates::EventTypeOrCategoryNotFound)
    end
  end
end
