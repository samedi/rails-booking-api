# frozen_string_literal: true

# Maps API response containing a comment form into a hierarchy of entities.
class CommentFormAPIMapper
  attr_reader :comment_form_field_api_mapper

  def initialize(comment_form_field_api_mapper: CommentFormFieldAPIMapper.new)
    @comment_form_field_api_mapper = comment_form_field_api_mapper
  end

  # Maps a single form data (which is just a collection of hashes that represent fields) into a {CommentForm}.
  # @param list [Array<Hash<String, Object>>] Data for comment form fields.
  # @param event_type_id [Integer] ID of the event type to which the form belongs.
  # @return [CommentForm] An instance that wraps comment form fields.
  def map_single(list, event_type_id:)
    list ||= []

    CommentForm.new(
      comment_form_field_api_mapper.map_collection(list),
      event_type_id: event_type_id
    )
  end
end
