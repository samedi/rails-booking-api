# frozen_string_literal: true

# Represents a date that can potentially be booked.
class EventDate
  attr_reader :institution
  attr_reader :event_category
  attr_reader :event_type

  # Gets a date that could be booked.
  # @return [Date] date
  attr_reader :date

  # Is the date available for booking?
  # @return [true, false] Availability
  def available?
    @available
  end

  def initialize(institution:, event_category:, event_type:, date:, available:)
    @institution = institution
    @event_category = event_category
    @event_type = event_type
    @date = Date.parse(date)
    @available = available
  end
end
