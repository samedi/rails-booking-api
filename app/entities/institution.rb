# frozen_string_literal: true

# Represents an institution that provides various events which can be booked.
class Institution
  attr_reader :id
  attr_reader :name

  def initialize(id:, name:)
    @id = id
    @name = name
  end
end
