# frozen_string_literal: true

# Form that provides values necessary to perform a booking.
class BookingDetails
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :institution_id, :string
  attribute :event_category_id, :integer
  attribute :event_type_id, :integer
  attribute :starts_at, :datetime
  attribute :token, :string
  attribute :comment_form

  validates :event_category_id, presence: true
  validates :event_type_id, presence: true
  validates :starts_at, presence: true
  validates :token, presence: true
  validate :comment_form_is_valid

  # Creates a new instance of the class with values prefilled from a Timeslot object.
  #
  # @param comment_form [CommentForm] CommentForm object that will be used to prepare the nested form for
  #   the structured comment.
  # @param timeslot [Timeslot] Timeslot object which will be used to prefill the data in the form.
  # @return [BookingDetails] A new instance of the class.
  def self.build_from_timeslot(comment_form, timeslot)
    new(
      comment_form,
      institution_id: timeslot.institution.id,
      event_category_id: timeslot.event_category.id,
      event_type_id: timeslot.event_type.id,
      starts_at: timeslot.time,
      token: timeslot.token,
      comment_form_attributes: nil
    )
  end

  # @param comment_form [CommentForm] CommentForm object that will be used to prepare the nested form for
  #   the structured comment.
  # @param params [HashWithIndifferentAccess] Values for form attributes.
  def initialize(comment_form, params)
    @comment_form_class = CommentFormModelBuilder.build(comment_form)
    super(params)
  end

  # Builds a new instance of the comment form model using the values from the form.
  # @param value [HashWithIndifferentAccess] Values for the structured comment form.
  def comment_form_attributes=(value)
    self.comment_form = comment_form_class.new(value)
  end

  # @return [Hash<String, Object>, nil] Hash of structured comment values, or nil if there is no comment form.
  def comment_form_hash
    comment_form&.to_hash
  end

  private

  # Used for parsing comemnt form attributes into a proper comment form object.
  #
  # Not a form attribute.
  attr_reader :comment_form_class

  def comment_form_is_valid
    return unless comment_form

    errors.add(:base, :comment_form_is_not_valid) unless comment_form.valid?
  end
end
