# frozen_string_literal: true

# Represents a bookable timeslot.
class Timeslot
  attr_reader :institution
  attr_reader :event_category
  attr_reader :event_type
  attr_reader :time
  attr_reader :token

  def initialize(institution:, event_category:, event_type:, time:, token:)
    @institution = institution
    @event_category = event_category
    @event_type = event_type
    @time = to_time(time)
    @token = token
  end

  private

  def to_time(time)
    case time
    when Time then time
    else Time.parse(time.to_s)
    end
  end
end
