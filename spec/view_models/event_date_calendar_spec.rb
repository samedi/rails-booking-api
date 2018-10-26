# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventDateCalendar do
  def build_event_date(date_string, available:)
    institution = Institution.new(id: '00JDFP8A3KYME1FA', name: 'Praxis Zweig (DEMO)')
    event_category = EventCategory.new(id: 50_409, institution: institution, name: 'Termin für Online-Videosprechstunde')
    event_type = EventType.new(id: 156_481, institution: institution, event_category: event_category, name: 'Sprechstunde')

    EventDate.new(
      institution: institution,
      event_category: event_category,
      event_type: event_type,
      date: date_string,
      available: available
    )
  end

  describe '#months' do
    it 'returns an array of EventDate arrays indexed by month and year string' do
      event_dates = [
        build_event_date('2018-06-01', available: false),
        build_event_date('2018-06-02', available: false),
        build_event_date('2018-07-01', available: true),
        build_event_date('2018-07-02', available: true)
      ]
      *june, first_july, second_july = event_dates
      I18n.locale = 'en'
      subject = described_class.new(event_dates)

      expect(subject.months).to eq(
        [[Date.new(2018, 6, 1), june], [Date.new(2018, 7, 1), [first_july, second_july]]]
      )
    end

    it 'ignores months with a single day' do
      event_dates = [
        build_event_date('2018-06-01', available: false),
        build_event_date('2018-06-02', available: false),
        build_event_date('2018-07-01', available: true),
        build_event_date('2018-07-02', available: true),
        build_event_date('2018-08-01', available: true)
      ]
      *june, first_july, second_july, _first_august = event_dates
      I18n.locale = 'en'
      subject = described_class.new(event_dates)

      expect(subject.months).to eq(
        [[Date.new(2018, 6, 1), june], [Date.new(2018, 7, 1), [first_july, second_july]]]
      )
    end
  end

  describe '#find_month_with_available_days' do
    it 'yields month name, days of month, the number of weekdays until the first day of the month, previous month, and next month of the first month with available dates' do
      event_dates = [
        build_event_date('2018-06-01', available: true),
        build_event_date('2018-06-02', available: false),
        build_event_date('2018-07-01', available: false),
        build_event_date('2018-07-02', available: true)
      ]
      *june, _, _ = event_dates
      I18n.locale = 'en'
      subject = described_class.new(event_dates, reference_date: Date.new(2018, 5, 1))

      expect { |probe| subject.find_month_with_available_days(&probe) }.to yield_with_args(
        'June 2018', june, 4, '2018-05', '2018-07'
      )
    end

    context 'when no month has available dates' do
      it 'yields month name, days of month, the number of weekdays until the first day of the month, previous month, and next month of the last month' do
        event_dates = [
          build_event_date('2018-06-01', available: false),
          build_event_date('2018-06-02', available: false),
          build_event_date('2018-07-01', available: false),
          build_event_date('2018-07-02', available: false),
          build_event_date('2018-08-01', available: false),
          build_event_date('2018-08-02', available: false)
        ]
        *, first_august, second_august = event_dates
        I18n.locale = 'en'
        subject = described_class.new(event_dates, reference_date: Date.new(2018, 5, 1))

        expect { |probe| subject.find_month_with_available_days(&probe) }.to yield_with_args(
          'August 2018', [first_august, second_august], 2, '2018-07', '2018-09'
        )
      end
    end

    context 'when only the last month has a single day that is available' do
      it 'yields month name, days of month, the number of weekdays until the first day of the month, previous month, and next month of the second month to last' do
        event_dates = [
          build_event_date('2018-06-01', available: false),
          build_event_date('2018-06-02', available: false),
          build_event_date('2018-07-01', available: false),
          build_event_date('2018-07-02', available: false),
          build_event_date('2018-08-01', available: true)
        ]
        *, first_july, second_july, _first_august = event_dates
        I18n.locale = 'en'
        subject = described_class.new(event_dates, reference_date: Date.new(2018, 5, 1))

        expect { |probe| subject.find_month_with_available_days(&probe) }.to yield_with_args(
          'July 2018', [first_july, second_july], 6, '2018-06', '2018-08'
        )
      end
    end

    context 'when the month is the same as the one in reference_date' do
      it 'yields month name, days of month, the number of weekdays until the first day of the month, `nil`, and next month of the first month with available dates' do
        event_dates = [
          build_event_date('2018-06-01', available: false),
          build_event_date('2018-06-02', available: false),
          build_event_date('2018-07-01', available: true),
          build_event_date('2018-07-02', available: true)
        ]
        *, first_july, second_july = event_dates
        I18n.locale = 'en'
        subject = described_class.new(event_dates, reference_date: Date.new(2018, 7, 1))

        expect { |probe| subject.find_month_with_available_days(&probe) }.to yield_with_args(
          'July 2018', [first_july, second_july], 6, nil, '2018-08'
        )
      end
    end
  end

  describe '#days_of_week' do
    it 'returns an array with very short weekday names' do
      I18n.locale = 'en'
      subject = described_class.new([])

      expect(subject.days_of_week).to eq(%w[M T W T F S S])
    end
  end

  describe '#each_day_of_week' do
    it 'yields every day of week' do
      I18n.locale = 'en'
      subject = described_class.new([])

      expect { |probe| subject.each_day_of_week(&probe) }.to yield_successive_args('M', 'T', 'W', 'T', 'F', 'S', 'S')
    end
  end

  describe '#weekdays_until' do
    context 'when week begins on Monday' do
      it 'returns 0 for 1st January 2018 when week begins on Monday' do
        I18n.locale = 'en'
        date = Date.new(2018, 1, 1)
        subject = described_class.new([])

        result = subject.weekdays_until(date)

        expect(result).to eq(0)
      end

      it 'returns 6 for 1st July 2018 when week begins on Monday' do
        I18n.locale = 'en'
        date = Date.new(2018, 7, 1)
        subject = described_class.new([])

        result = subject.weekdays_until(date)

        expect(result).to eq(6)
      end
    end

    context 'when week begins on Sunday' do
      before do
        I18n.locale = 'en'
        @previous_first_day_of_week = I18n.t('calendar.first_day_of_week')
        I18n.backend.store_translations('en', calendar: { first_day_of_week: 0 })
      end

      after do
        I18n.backend.store_translations('en', calendar: { first_day_of_week: @previous_first_day_of_week })
      end

      it 'returns 1 for 1st January 2018 when week begins on Monday' do
        I18n.locale = 'en'
        date = Date.new(2018, 1, 1)
        subject = described_class.new([])

        result = subject.weekdays_until(date)

        expect(result).to eq(1)
      end

      it 'returns 0 for 1st July 2018' do
        date = Date.new(2018, 7, 1)
        subject = described_class.new([])

        result = subject.weekdays_until(date)

        expect(result).to eq(0)
      end
    end
  end
end
