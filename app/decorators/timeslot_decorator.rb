# frozen_string_literal: true

# Decorates the {Timeslot} entity to provide view-related methods.
class TimeslotDecorator < SimpleDelegator
  def self.decorate_collection(timeslots)
    timeslots.map { |timeslot| new(timeslot) }
  end

  def new_booking_path_args
    {
      institution_id: institution.id,
      event_category_id: event_category.id,
      event_type_id: event_type.id,
      time: time.iso8601,
      token: token
    }
  end
end
