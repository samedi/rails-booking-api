# frozen_string_literal: true

# Provides actions for reviewing and performing bookings.
class BookingsController < ApplicationController
  def new
    @institution, @event_category, @event_type = fetch_institution_category_and_type(params)
    @timeslot = build_timeslot(@event_type, time: params.fetch(:time), token: params.fetch(:token))
    @booking_details = BookingDetails.build_from_timeslot(@event_type.comment_form, @timeslot)
  end

  def create
    @institution, @event_category, @event_type = fetch_institution_category_and_type(booking_details_unsafe_hash)
    @booking_details = BookingDetails.new(@event_type.comment_form, booking_details_unsafe_hash)
    @timeslot = build_timeslot(@event_type, time: @booking_details.starts_at, token: @booking_details.token)

    if @booking_details.invalid?
      render :new
      return
    end

    book_and_redirect_to_success(@timeslot, @booking_details)
  end

  def success
    @booking_confirmation = BookingConfirmation.new(id: params.fetch(:id))
  end

  private

  def fetch_institution_category_and_type(params)
    institution_id = params.fetch(:institution_id)
    event_category_id = params.fetch(:event_category_id)
    event_type_id = params.fetch(:event_type_id)

    fetch = FetchInstitutionCategoryAndType.new
    fetch.call(institution_id: institution_id, event_category_id: event_category_id, event_type_id: event_type_id)
  end

  def build_timeslot(event_type, time:, token:)
    Timeslot.new(
      institution: event_type.institution,
      event_category: event_type.event_category,
      event_type: event_type,
      time: time,
      token: token
    )
  end

  def book_and_redirect_to_success(timeslot, booking_details)
    booking = BookEvent.new.call(
      patient: current_patient,
      timeslot: timeslot,
      structured_comment: booking_details.comment_form_hash
    )

    redirect_to success_booking_url(booking.id)
  end

  def booking_details_unsafe_hash
    params.fetch(:booking_details).to_unsafe_h
  end
end
