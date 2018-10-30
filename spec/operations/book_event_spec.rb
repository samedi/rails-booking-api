# frozen_string_literal: true

require 'json'
require 'faraday'
require 'faraday_middleware'
require 'time'
require 'samedi'
require 'samedi/patient_api'
require 'samedi/patient_api/connection_provider'
require 'patient'
require 'institution'
require 'event_category'
require 'event_type'
require 'timeslot'
require 'fetch_timeslots'
require 'booking_confirmation'
require 'book_event'
require 'test_service_container'

RSpec.describe BookEvent do
  describe '#call' do
    let(:today) { Date.new(2018, 10, 30) }

    it 'responds with a BookingConfirmation', vcr: { cassette_name: 'book_event' } do
      patient = Patient.new(access_token: ENV['TEST_ACCESS_TOKEN'])
      institution = Institution.new(id: '00JDFP8A3KYME1FA', name: 'Praxis Zweig (DEMO)')
      event_category = EventCategory.new(id: 50_409, institution: institution, name: 'Termin für Online-Videosprechstunde')
      event_type = EventType.new(id: 156_481, institution: institution, event_category: event_category, name: 'Sprechstunde')

      # fetch timeslots
      next_monday = today - today.wday + 8 # Date#wday return 0 for Sunday
      friday_5_weeks_later = next_monday + 4 + (4 * 7)

      timeslots = FetchTimeslots.new(connection_provider: TestServiceContainer.booking_connection_provider).call(
        event_type: event_type,
        from_date: next_monday,
        to_date: friday_5_weeks_later
      )

      next_timeslot = timeslots.first

      subject = described_class.new(connection_provider: TestServiceContainer.booking_connection_provider)

      result = subject.call(
        patient: patient,
        timeslot: next_timeslot
      )

      expect(result).to be_a(BookingConfirmation)
    end

    it 'fails when required comment fields are not sent', vcr: { cassette_name: 'book_event_without_structured_comment' } do
      patient = Patient.new(access_token: ENV['TEST_ACCESS_TOKEN'])
      institution = Institution.new(id: '2kqsyve1h4t0dyv5', name: 'Klinik Morgen (TEST) / - DIES IST EIN TESTKONTOPraxis Zweig (DEMO)')
      event_category = EventCategory.new(id: 28_889, institution: institution, name: 'Zahnmedizin')
      event_type = EventType.new(id: 89_871, institution: institution, event_category: event_category, name: 'Prophylaxe')

      # fetch timeslots
      next_monday = today - today.wday + 8 # Date#wday return 0 for Sunday
      friday_5_weeks_later = next_monday + 4 + (4 * 7)

      timeslots = FetchTimeslots.new(connection_provider: TestServiceContainer.booking_connection_provider).call(
        event_type: event_type,
        from_date: next_monday,
        to_date: friday_5_weeks_later
      )

      next_timeslot = timeslots.first

      subject = described_class.new(connection_provider: TestServiceContainer.booking_connection_provider)

      expect {
        subject.call(
          patient: patient,
          timeslot: next_timeslot
        )
      }.to(raise_error { |e|
        e.is_a?(BookEvent::CommentFormValidationError) &&
          e.errors == [{ 'Neupatient' => 'muss ausgefüllt werden' },
                       { 'Vorerkrankungen' => 'muss ausgefüllt werden' }]
      })
    end

    it 'succeeds when required comment fields are sent', vcr: { cassette_name: 'book_event_with_structured_comment' } do
      patient = Patient.new(access_token: ENV['TEST_ACCESS_TOKEN'])
      institution = Institution.new(id: '2kqsyve1h4t0dyv5', name: 'Klinik Morgen (TEST) / - DIES IST EIN TESTKONTOPraxis Zweig (DEMO)')
      event_category = EventCategory.new(id: 28_889, institution: institution, name: 'Zahnmedizin')
      event_type = EventType.new(id: 89_871, institution: institution, event_category: event_category, name: 'Prophylaxe')

      # fetch timeslots
      next_monday = today - today.wday + 8 # Date#wday return 0 for Sunday
      friday_5_weeks_later = next_monday + 4 + (4 * 7)

      timeslots = FetchTimeslots.new(connection_provider: TestServiceContainer.booking_connection_provider).call(
        event_type: event_type,
        from_date: next_monday,
        to_date: friday_5_weeks_later
      )

      next_timeslot = timeslots.first

      structured_comment = {
        'Neupatient' => 'JA, NEIN',
        'Vorerkrankungen' => 'Test'
      }

      subject = described_class.new(connection_provider: TestServiceContainer.booking_connection_provider)

      subject.call(
        patient: patient,
        timeslot: next_timeslot,
        structured_comment: structured_comment
      )
    end
  end
end
