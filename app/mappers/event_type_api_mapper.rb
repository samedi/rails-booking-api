# frozen_string_literal: true

# Maps API response containing an event type to the entity.
class EventTypeAPIMapper
  attr_reader :comment_form_mapper

  def initialize(comment_form_mapper: CommentFormAPIMapper.new)
    @comment_form_mapper = comment_form_mapper
  end

  # Maps a collection of event types into an array of {EventType}.
  # @param list [Array<Hash<String, Object>>] Event types data.
  # @param event_category [EventCategory] Event category to which the types belongs.
  # @return [Array<EventType>] Entities wrapping the data returned from the API.
  def map_collection(list, event_category:)
    list.map { |hash| map_single(hash, event_category: event_category) }
  end

  # Maps a single event type into {EventType}.
  # @param hash [Hash<String, Object>] Event type data.
  # @param event_category [EventCategory] Event category to which this type belongs.
  # @return [EventType] Entity wrapping the data returned from the API.
  def map_single(hash, event_category:)
    id = hash.fetch('id')

    EventType.new(
      id: id,
      event_category: event_category,
      institution: event_category.institution,
      name: hash.fetch('name'),
      description: hash.fetch('description'),
      comment_form: comment_form_mapper.map_single(hash.fetch('comment_form'), event_type_id: id)
    )
  end
end
