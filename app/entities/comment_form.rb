# frozen_string_literal: true

# A comment form belonging to an event type.
class CommentForm
  # @return [Array<CommentFormField> Collection of fields that make up the form.
  attr_reader :fields

  # @return [Integer] ID of an event type to which the form belongs.
  attr_reader :event_type_id

  def initialize(fields, event_type_id:)
    @fields = fields.freeze
    @event_type_id = event_type_id
  end

  def ==(other)
    fields == other.fields &&
      event_type_id == other.event_type_id
  end
  alias eql? ==

  def hash
    [fields, event_type_id].hash
  end
end
