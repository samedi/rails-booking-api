# frozen_string_literal: true

# Represents a patient that can book an event.
class Patient
  attr_reader :access_token

  def initialize(access_token:)
    @access_token = access_token
  end
end
