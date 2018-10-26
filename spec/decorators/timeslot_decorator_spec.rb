# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TimeslotDecorator do
  describe '.decorate_collection' do
    it 'decorates an array of Timeslot objects' do
      institution = Institution.new(id: '00JDFP8A3KYME1FA', name: 'Praxis Zweig (DEMO)')
      event_category = EventCategory.new(id: 50_409, institution: institution, name: 'Termin für Online-Videosprechstunde')
      event_type = EventType.new(id: 156_481, institution: institution, event_category: event_category, name: 'Sprechstunde')

      timeslots = [
        Timeslot.new(institution: institution, event_category: event_category, event_type: event_type, time: Time.now, token: 'foo'),
        Timeslot.new(institution: institution, event_category: event_category, event_type: event_type, time: Time.now, token: 'bar')
      ]

      result = described_class.decorate_collection(timeslots)

      expect(result.size).to eq timeslots.size
      expect(result).to all(be_a TimeslotDecorator)
    end
  end
end
