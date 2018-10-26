# frozen_string_literal: true

# Encapsulates data necessary to build an ActiveModel attribute representing a form field
class CommentFormFieldAttribute
  # Type that represents a combo box form field.
  #
  # It accepts only values that have been defined upon initialization.
  class ComboType < ActiveModel::Type::Value
    attr_reader :values

    def initialize(values)
      @values = values
    end

    private

    def cast_value(value)
      value if values.include?(value)
    end
  end

  # Type that represents a combo box with multiple selection.
  #
  # It accepts only values that have been defined upon initialization.
  class MultiComboType < ComboType
    private

    def cast_value(value)
      values & Array(value)
    end
  end

  FIELD_TYPE_TO_ACTIVE_MODEL_TYPE = {
    'checkbox' => :boolean,
    'date' => :date,
    'time' => :time,
    'duration' => :time,
    'combo' => lambda do |config|
      if config.multi?
        MultiComboType.new(config.values)
      else
        ComboType.new(config.values)
      end
    end
  }.freeze

  attr_reader :comment_form_field
  attr_reader :name
  attr_reader :type
  attr_reader :validation

  # Sets up the instance from a single {CommentFormField}
  # @param comment_form_field [CommentFormField]
  def initialize(comment_form_field)
    @comment_form_field = comment_form_field
    @name = field_name_to_attribute_name(comment_form_field.name)
    @type = field_type_to_activemodel_type(comment_form_field)
    @validation = field_validation(comment_form_field)
  end

  alias required? validation

  private

  def field_name_to_attribute_name(field_name)
    field_name.downcase.gsub(/[^[[:alnum:]]]+/, '_')
  end

  def field_type_to_activemodel_type(comment_form_field)
    am_type = FIELD_TYPE_TO_ACTIVE_MODEL_TYPE.fetch(comment_form_field.type) { :string }

    if am_type.respond_to?(:call)
      am_type.call(comment_form_field.config)
    else
      am_type
    end
  end

  def field_validation(comment_form_field)
    return unless comment_form_field.required?

    if comment_form_field.type == 'checkbox'
      { acceptance: true, inclusion: { in: [true, false] } }
    else
      { presence: true }
    end
  end
end
