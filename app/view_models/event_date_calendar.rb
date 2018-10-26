# frozen_string_literal: true

# A view-model that represents an event date picker calendar.
class EventDateCalendar
  attr_reader :event_dates
  attr_reader :reference_date

  # @param event_dates [Array<EventDate>] Event dates to display
  def initialize(event_dates, reference_date: Date.today)
    @event_dates = event_dates
    @reference_date = reference_date
  end

  # Yields event dates grouped by a month.
  #
  # For every month yields 3 arguments.
  # @yieldparam month [String] a name of the month
  # @yieldparam event_dates_in_month [Array<EventDate>] EventDate objects within the calendar month
  # @yieldparam weekdays_until_first_day [Integer] Number of weekdays until the first date in this month
  def find_month_with_available_days
    month, event_dates_in_month = first_available_or_last_month
    previous_month, next_month = previous_and_next_months(month)

    yield(
      month_name(month),
      event_dates_in_month,
      weekdays_until(event_dates_in_month.first.date),
      previous_month,
      next_month
    )
  end

  # Yields for every day of the week, using the current locale.
  # yieldparam day_name [String] name of the weekday
  def each_day_of_week
    days_of_week.each { |dow| yield dow }
  end

  def first_available_or_last_month
    months.each.find { |_, event_dates| event_dates.any?(&:available?) } || months.last
  end

  def months
    event_dates
      .group_by { |ed| Date.new(ed.date.year, ed.date.month) }
      .reject { |_, event_dates| event_dates.length == 1 }
      .to_a
  end

  def days_of_week
    day_names = I18n.t('calendar.very_short_day_names')

    Array.new(7) { |day_of_week|
      locale_indexed_day_of_week = (day_of_week + first_day_of_week) % 7

      day_names[locale_indexed_day_of_week]
    }
  end

  def weekdays_until(date)
    (date.wday - first_day_of_week) % 7
  end

  def previous_and_next_months(month)
    previous_month = month.last_month
    previous_month = previous_month < reference_date.beginning_of_month ? nil : previous_month

    next_month = month.next_month

    [previous_month&.strftime('%Y-%m'), next_month.strftime('%Y-%m')]
  end

  private

  def month_name(month)
    I18n.l(month, format: :month_and_year)
  end

  def first_day_of_week
    I18n.t('calendar.first_day_of_week')
  end
end
