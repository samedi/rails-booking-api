# frozen_string_literal: true

# A single field for an event type's comment form.
class CommentFormField
  # Encapsulates configuration for more complex form fields.
  class Configuration
    # @return ['past', 'future', nil] Restriction for date picker
    attr_reader :restriction

    # @return [Array<String>] Values for a combo box
    attr_reader :values

    # @return [String] A placeholder or prompt
    attr_reader :empty_text

    def initialize(restriction: nil, values: nil, empty_text: nil, multi: nil)
      @restriction = restriction
      @values = values
      @empty_text = empty_text
      @multi = multi
    end

    # @return [true, false] Whether a combo box supports multiple selection
    def multi?
      @multi
    end

    def ==(other)
      restriction == other.restriction &&
        values == other.values &&
        empty_text == other.empty_text &&
        multi? == other.multi?
    end
    alias eql? ==

    def hash
      [restriction, values, empty_text, multi?].hash
    end

    def inspect
      [
        restriction ? "restriction: #{restriction}" : nil,
        empty_text ? "empty_text: #{empty_text.inspect}" : nil,
        multi? ? 'multi' : nil,
        values ? "values: #{values.inspect}" : nil
      ].compact.join(' ').yield_self { |str| "<#{str}>" }
    end
  end

  # @return [String] Name of the field. Both the user-facing label and the key
  #   by which the value should be sent when booking.
  attr_reader :name

  # @return [String] Type of the field. The following types are supported, but the value
  #   can include arbitrary text as well: 'textfield', `textarea`, `date`, `time`,
  #   `duration`, `combo`, `checkbox`.
  attr_reader :type

  # @return [Configuration] Configuration for more advanced options
  attr_reader :config

  def initialize(name:, required:, type:, config:)
    @name = name
    @required = required
    @type = type
    @config = config
  end

  # @return [true, false] Whether the field is required
  def required?
    @required
  end

  def ==(other)
    name == other.name &&
      required? == other.required? &&
      type == other.type &&
      config == other.config
  end
  alias eql? ==

  def hash
    [name, required?, type, config].hash
  end

  def inspect
    [
      "#{type}=#{name.inspect}",
      required? ? 'required' : nil,
      "config=#{config.inspect}"
    ].compact.join(' ').yield_self { |str| "<#{str}>" }
  end
end
