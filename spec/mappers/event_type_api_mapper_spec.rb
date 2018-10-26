# frozen_string_literal: true

require 'institution'
require 'event_category'
require 'event_type'
require 'event_type_api_mapper'

RSpec.describe EventTypeAPIMapper do
  describe '#map_single' do
    it 'returns EventType that matches the hash provided' do
      hash = {
        'id' => 156_481,
        'name' => 'Sprechstunde',
        'attendant_user_required' => true,
        'description' =>
          '<p>Hiermit buchen Sie&nbsp;verbindlich&nbsp;einen Termin für eine Sprechstunde in der Praxis - über den&nbsp;Arzttermin-Online-Service (tk.samedi.de) Ihrer Techniker Krankenkasse (TK).&nbsp;</p>\n',
        'is_video_consultation' => true,
        'patient_can_book_without_account' => true,
        'comment_form' => nil
      }
      institution = Institution.new(id: 'BCMNWE2W3N2R3Z4K', name: 'Krankenkasse VM')
      event_category = EventCategory.new(id: 50_409, institution: institution, name: 'Dr. Peter')
      comment_form_mapper = instance_double('CommentFormAPIMapper', map_single: nil)
      subject = described_class.new(comment_form_mapper: comment_form_mapper)

      result = subject.map_single(hash, event_category: event_category)

      expect(result.id).to eq(156_481)
      expect(result.event_category).to eq(event_category)
      expect(result.institution).to eq(institution)
      expect(result.name).to eq('Sprechstunde')
      expect(result.description).to include('Hiermit buchen Sie')
    end

    it 'delegates mapping of comment forms to CommentFormAPIMapper' do
      hash = {
        'id' => 156_481,
        'name' => 'Sprechstunde',
        'attendant_user_required' => true,
        'description' =>
          '<p>Hiermit buchen Sie&nbsp;verbindlich&nbsp;einen Termin für eine Sprechstunde in der Praxis - über den&nbsp;Arzttermin-Online-Service (tk.samedi.de) Ihrer Techniker Krankenkasse (TK).&nbsp;</p>\n',
        'is_video_consultation' => true,
        'patient_can_book_without_account' => true,
        'comment_form' => [
          { 'name' => 'Foo' },
          { 'name' => 'Vorerkrankungen' }
        ]
      }
      institution = Institution.new(id: 'BCMNWE2W3N2R3Z4K', name: 'Krankenkasse VM')
      event_category = EventCategory.new(id: 50_409, institution: institution, name: 'Dr. Peter')
      comment_form_mapper = instance_spy('CommentFormAPIMapper')
      subject = described_class.new(comment_form_mapper: comment_form_mapper)

      subject.map_single(hash, event_category: event_category)

      expect(comment_form_mapper).to have_received(:map_single).with(
        a_collection_containing_exactly(
          hash_including('name' => 'Foo'),
          hash_including('name' => 'Vorerkrankungen')
        ),
        event_type_id: 156_481
      )
    end
  end

  describe '#map_collection' do
    it 'returns an array of EventType entities that matches the hashes provided' do
      list = [
        {
          'id' => 156_481,
          'name' => 'Sprechstunde',
          'attendant_user_required' => true,
          'description' =>
            '<p>Hiermit buchen Sie&nbsp;verbindlich&nbsp;einen Termin für eine Sprechstunde in der Praxis - über den&nbsp;Arzttermin-Online-Service (tk.samedi.de) Ihrer Techniker Krankenkasse (TK).&nbsp;</p>\n',
          'is_video_consultation' => true,
          'patient_can_book_without_account' => true,
          'comment_form' => nil
        },
        {
          'id' => 156_482,
          'name' => 'Foo Baz',
          'attendant_user_required' => false,
          'description' => '',
          'is_video_consultation' => false,
          'patient_can_book_without_account' => false,
          'comment_form' => nil
        }
      ]
      institution = Institution.new(id: 'BCMNWE2W3N2R3Z4K', name: 'Krankenkasse VM')
      event_category = EventCategory.new(id: 50_409, institution: institution, name: 'Dr. Peter')
      comment_form_mapper = instance_double('CommentFormAPIMapper', map_single: nil)
      subject = described_class.new(comment_form_mapper: comment_form_mapper)

      first, second = subject.map_collection(list, event_category: event_category)

      expect(first.id).to eq(156_481)
      expect(first.event_category).to eq(event_category)
      expect(first.institution).to eq(institution)
      expect(first.name).to eq('Sprechstunde')

      expect(second.id).to eq(156_482)
      expect(second.institution).to eq(institution)
      expect(second.name).to eq('Foo Baz')
    end
  end
end
