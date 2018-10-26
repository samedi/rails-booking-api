# frozen_string_literal: true

# A facade for fetching institution, event category, and event type at once.
#
# This pattern is often necessary in controllers so this is a helper.
class FetchInstitutionCategoryAndType
  def initialize(
    fetch_institution_details: ServiceContainer.fetch_institution_details,
    fetch_event_categories: ServiceContainer.fetch_event_categories,
    fetch_event_types: ServiceContainer.fetch_event_types
  )
    @fetch_institution_details = fetch_institution_details
    @fetch_event_categories = fetch_event_categories
    @fetch_event_types = fetch_event_types
  end

  # Finds an institution, an event category, and an event type by their IDs.
  # @param institution_id [Integer,String] ID of an institution
  # @param event_type_id [Integer,String] ID of an event type
  # @param event_category_id [Integer,String] ID of en event category
  # @return [Array<(Institution, EventCategory, EventType)>] an array that has exactly one institution, one event
  #   category, and one event type
  def call(institution_id:, event_type_id:, event_category_id:)
    institution = fetch_institution(institution_id)
    event_category = fetch_event_category(institution, event_category_id)
    event_type = fetch_event_type(event_category, event_type_id)

    [institution, event_category, event_type]
  end

  private

  def fetch_institution(institution_id)
    @fetch_institution_details.call(institution_id: institution_id)
  end

  def fetch_event_category(institution, event_category_id)
    @fetch_event_categories.find_single(
      institution: institution,
      event_category_id: event_category_id
    )
  end

  def fetch_event_type(event_category, event_type_id)
    @fetch_event_types.find_single(
      event_category: event_category,
      event_type_id: event_type_id
    )
  end
end
