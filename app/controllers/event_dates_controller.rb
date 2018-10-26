# frozen_string_literal: true

# Provides actions related to event dates.
class EventDatesController < ApplicationController
  def index
    @institution, @event_category, @event_type = fetch_institution_category_and_type(params)

    month_string = params[:month]
    range =
      if month_string
        Date.iso8601("#{month_string}-01")
      else
        :find_available
      end

    event_dates = FetchEventDates.new.call(event_type: @event_type, range: range)
    @event_date_calendar = EventDateCalendar.new(event_dates)
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
