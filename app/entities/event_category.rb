# frozen_string_literal: true

# Represents an event category that can be booked.
class EventCategory
  attr_reader :id
  attr_reader :institution
  attr_reader :name
  attr_reader :description
  attr_reader :subtitle
  attr_reader :photo_url

  def initialize( # rubocop:disable Metrics/ParameterLists
    id:, institution:, name:, description: nil, subtitle: nil, photo_url: nil
  )
    @id = id
    @institution = institution
    @name = name
    @description = description
    @subtitle = subtitle
    @photo_url = photo_url
  end
end
