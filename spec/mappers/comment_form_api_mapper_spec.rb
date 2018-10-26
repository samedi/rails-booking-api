# frozen_string_literal: true

require 'comment_form'
require 'comment_form_api_mapper'

RSpec.describe CommentFormAPIMapper do
  describe '#map_single' do
    it 'returns CommentForm that keeps reference to event_type_id' do
      list = []
      event_type_id = 42
      comment_form_field_api_mapper = instance_double('CommentFormFieldAPIMapper', map_collection: nil)
      subject = described_class.new(comment_form_field_api_mapper: comment_form_field_api_mapper)

      result = subject.map_single(list, event_type_id: event_type_id)

      expect(result.event_type_id).to eq(event_type_id)
    end

    it 'delegates mapping of fields to the specified `comment_form_field_api_mapper`' do
      list = [
        { 'name' => 'Vorerkrankungen', 'required' => true, 'type' => 'textfield', 'config' => nil },
        { 'name' => 'Adresse', 'required' => true, 'type' => 'textarea', 'config' => nil }
      ]
      event_type_id = 42
      comment_form_field_api_mapper = instance_spy('CommentFormFieldAPIMapper', map_collection: [])
      subject = described_class.new(comment_form_field_api_mapper: comment_form_field_api_mapper)

      subject.map_single(list, event_type_id: event_type_id)

      expect(comment_form_field_api_mapper).to have_received(:map_collection).with(list)
    end

    it 'will map an empty array into fields when `nil` is given' do
      event_type_id = 42
      comment_form_field_api_mapper = instance_spy('CommentFormFieldAPIMapper', map_collection: [])
      subject = described_class.new(comment_form_field_api_mapper: comment_form_field_api_mapper)

      subject.map_single(nil, event_type_id: event_type_id)

      expect(comment_form_field_api_mapper).to have_received(:map_collection).with([])
    end
  end
end
