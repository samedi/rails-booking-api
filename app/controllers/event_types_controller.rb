# frozen_string_literal: true

# Provides actions related to event types.
class EventTypesController < ApplicationController
  def index
    institution_id = params.fetch(:institution_id)
    event_category_id = params.fetch(:event_category_id)

    @institution = FetchInstitutionDetails.new.call(institution_id: institution_id)
    @event_category = FetchEventCategories.new.find_single(
      institution: @institution, event_category_id: event_category_id
    )
    @event_types = FetchEventTypes.new.call(event_category: @event_category)
  end
end
