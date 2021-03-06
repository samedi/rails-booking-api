# frozen_string_literal: true

# Provides actions related to event categories.
class EventCategoriesController < ApplicationController
  def index
    institution_id = params.fetch(:institution_id).strip
    unless institution_id.present?
      redirect_to root_url
      return
    end

    @institution = FetchInstitutionDetails.new.call(institution_id: institution_id)
    @event_categories = FetchEventCategories.new.call(institution: @institution)
  end
end
