# frozen_string_literal: true

# Maps API response containing a comment form field into the entity.
class CommentFormFieldAPIMapper
  # Maps a collection of comment form fields into an array of {CommentFormField}.
  # @param list [Array<Hash<String, Object>>] Data for comment form fields.
  # @return [Array<EventType>] Entities wrapping the data returned from the API.
  def map_collection(list)
    list.map { |hash| map_single(hash) }
  end

  # Maps a single comment form field into {CommentFormField}.
  # @param hash [Hash<String, Object>] Comment form field data.
  # @return [CommentFormField] Entity wrapping the data returned from the API.
  def map_single(hash)
    CommentFormField.new(
      name: hash.fetch('name'),
      required: hash.fetch('required'),
      type: hash.fetch('type'),
      config: map_config(hash.fetch('config'))
    )
  end

  private

  def map_config(hash)
    hash ||= {}

    values = hash['values']
    values = values.split("\n") if values

    CommentFormField::Configuration.new(
      restriction: hash['restriction'],
      values: values,
      empty_text: hash['emptyText'],
      multi: hash['multi'] == 'on'
    )
  end
end
