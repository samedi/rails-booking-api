# frozen_string_literal: true

require 'comment_form_field'
require 'comment_form'

RSpec.describe CommentForm do
  describe '#fields' do
    specify 'are frozen' do
      comment_form = CommentForm.new([], event_type_id: 1)
      expect(comment_form.fields).to be_frozen
    end
  end

  describe '#==' do
    specify '2 forms are equal if their fields and event type are equal' do
      first = CommentForm.new(
        [
          CommentFormField.new(name: 'foo', required: true, type: 'textfield',
                               config: CommentFormField::Configuration.new)
        ],
        event_type_id: 1
      )
      second = CommentForm.new(
        [
          CommentFormField.new(name: 'foo', required: true, type: 'textfield',
                               config: CommentFormField::Configuration.new)
        ],
        event_type_id: 1
      )

      expect(first).to eq(second)
    end

    specify '2 forms are different if their fields or event type are different' do
      first = CommentForm.new(
        [
          CommentFormField.new(name: 'foo', required: true, type: 'textfield',
                               config: CommentFormField::Configuration.new)
        ],
        event_type_id: 1
      )
      different_fields = CommentForm.new(
        [
          CommentFormField.new(name: 'foo', required: false, type: 'textfield',
                               config: CommentFormField::Configuration.new)
        ],
        event_type_id: 1
      )
      different_event_type_id = CommentForm.new(
        [
          CommentFormField.new(name: 'foo', required: true, type: 'textfield',
                               config: CommentFormField::Configuration.new)
        ],
        event_type_id: 2
      )

      expect(first).not_to eq(different_fields)
      expect(first).not_to eq(different_event_type_id)
    end
  end

  describe '#hash' do
    specify '2 forms have same hash if their fields and event type are equal' do
      first = CommentForm.new(
        [
          CommentFormField.new(name: 'foo', required: true, type: 'textfield',
                               config: CommentFormField::Configuration.new)
        ],
        event_type_id: 1
      )
      second = CommentForm.new(
        [
          CommentFormField.new(name: 'foo', required: true, type: 'textfield',
                               config: CommentFormField::Configuration.new)
        ],
        event_type_id: 1
      )

      expect(first.hash).to eq(second.hash)
    end

    specify '2 forms have different hashes if their fields or event type are different' do
      first = CommentForm.new(
        [
          CommentFormField.new(name: 'foo', required: true, type: 'textfield',
                               config: CommentFormField::Configuration.new)
        ],
        event_type_id: 1
      )
      different_fields = CommentForm.new(
        [
          CommentFormField.new(name: 'foo', required: false, type: 'textfield',
                               config: CommentFormField::Configuration.new)
        ],
        event_type_id: 1
      )
      different_event_type_id = CommentForm.new(
        [
          CommentFormField.new(name: 'foo', required: true, type: 'textfield',
                               config: CommentFormField::Configuration.new)
        ],
        event_type_id: 2
      )

      expect(first.hash).not_to eq(different_fields.hash)
      expect(first.hash).not_to eq(different_event_type_id.hash)
    end
  end
end
