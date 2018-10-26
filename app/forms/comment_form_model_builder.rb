# frozen_string_literal: true

# Builds a form object for a comment form
module CommentFormModelBuilder
  module_function

  # Builds an ActiveModel-backed form object for a given {CommentForm}.
  #
  # The ActiveModel form object will have an attribute for every defined field and presence validations
  # for all required fields.
  #
  # The form object relies on ActiveModel::Attributes for casting any values to appropriate types.
  # @see CommentFormFieldAttribute::ComboType
  # @see CommentFormFieldAttribute::MultiComboType
  #
  # The created anonymous classes are memoized by comment form, so this builder should not produce
  # memory leaks.
  #
  # @param comment_form [CommentForm] A comment form for which the model will be created.
  # @return [CommentFormBase] An anonymous subclass of CommentFormBase with attributes matching comment form fields.
  def build(comment_form)
    @memo ||= {}
    return @memo[comment_form] if @memo.key?(comment_form)

    attributes = comment_form.fields.map { |field| CommentFormFieldAttribute.new(field) }
    @memo[comment_form] = build_model(attributes)
  end

  def build_model(attributes)
    Class.new(CommentFormBase) do
      attributes.each do |attr|
        attribute attr.name, attr.type
        map attribute: attr.name, to: attr.comment_form_field

        next unless attr.required?

        validates attr.name, attr.validation
      end
    end
  end
end
