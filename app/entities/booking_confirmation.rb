# frozen_string_literal: true

# Represents a booking confirmation response.
class BookingConfirmation
  attr_reader :id

  def initialize(id:)
    @id = id
  end
end
