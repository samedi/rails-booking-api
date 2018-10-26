# frozen_string_literal: true

# Provides actions related to timeslots.
class EventTimeslotsController < ApplicationController
  def index
    @institution, @event_category, @event_type = fetch_institution_category_and_type(params)
    @date = params.fetch(:event_date).to_date

    timeslots = FetchTimeslots.new.call(event_type: @event_type, date: @date)
    @timeslots = TimeslotDecorator.decorate_collection(timeslots)
  end

  private

  def fetch_institution_category_and_type(params)
    institution_id = params.fetch(:institution_id)
    event_category_id = params.fetch(:event_category_id)
    event_type_id = params.fetch(:event_type_id)

    fetch = FetchInstitutionCategoryAndType.new
    fetch.call(institution_id: institution_id, event_category_id: event_category_id, event_type_id: event_type_id)
  end
end
