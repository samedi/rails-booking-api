# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BookingDetails do
  describe '.from_timeslot' do
    it 'assigns attributes from a Timeslot' do
      institution = Institution.new(id: '00JDFP8A3KYME1FA', name: 'Praxis Zweig (DEMO)')
      event_category = EventCategory.new(id: 50_409, institution: institution, name: 'Termin für Online-Videosprechstunde')
      event_type = EventType.new(id: 156_481, institution: institution, event_category: event_category, name: 'Sprechstunde')
      comment_form = CommentForm.new([], event_type_id: 1337)
      timeslot = Timeslot.new(
        institution: institution,
        event_category: event_category,
        event_type: event_type,
        time: Time.new(2018, 7, 16, 14, 30, 28),
        token: 'abc123'
      )

      result = described_class.build_from_timeslot(comment_form, timeslot)

      expect(result.institution_id).to eq('00JDFP8A3KYME1FA')
      expect(result.event_category_id).to eq(50_409)
      expect(result.event_type_id).to eq(156_481)
      expect(result.starts_at).to eq(Time.new(2018, 7, 16, 14, 30, 28))
      expect(result.token).to eq('abc123')
    end
  end
end
