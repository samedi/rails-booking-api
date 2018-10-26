# frozen_string_literal: true

# Represents an event type that can be booked.
#
# An event type has a comment form hash that describes additional fields that need
# to be completed by a patient for booking.
class EventType
  attr_reader :id
  attr_reader :event_category
  attr_reader :institution
  attr_reader :name
  attr_reader :description
  attr_reader :comment_form

  def initialize( # rubocop:disable Metrics/ParameterLists
    id:, event_category:, institution:, name:,
    description: nil, comment_form: nil
  )
    @id = id
    @event_category = event_category
    @institution = institution
    @name = name
    @description = description
    @comment_form = comment_form
  end
end
