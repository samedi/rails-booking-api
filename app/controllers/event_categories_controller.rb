# frozen_string_literal: true

# Provides actions related to event categories.
class EventCategoriesController < ApplicationController
  def index
    institution_id = params.fetch(:institution_id)

    @institution = FetchInstitutionDetails.new.call(institution_id: institution_id)
    @event_categories = FetchEventCategories.new.call(institution: @institution)
  end
end
