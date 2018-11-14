# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommentFormModelBuilder do
  describe '.build' do
    it 'returns an ActiveModel::Model class with no attributes when given a form with no fields' do
      event_type_id = 42
      comment_form = CommentForm.new([], event_type_id: event_type_id)

      result = described_class.build(comment_form)

      expect(result.ancestors).to include(ActiveModel::Model)
      expect(result.attribute_types).to be_empty
    end

    it 'returns an ActiveModel::Model class with model_name set to "CommentForm"' do
      event_type_id = 42
      comment_form = CommentForm.new([], event_type_id: event_type_id)

      result = described_class.build(comment_form)

      expect(result.model_name).to eq('CommentForm')
    end

    it 'returns an ActiveModel::Model class with attributes matching form fields' do
      event_type_id = 42
      comment_form = CommentForm.new(
        [
          CommentFormField.new(
            name: 'Foo Bar',
            type: 'text',
            required: false,
            config: CommentFormField::Configuration.new
          ),
          CommentFormField.new(
            name: 'Bäß',
            type: 'text',
            required: false,
            config: CommentFormField::Configuration.new
          )
        ],
        event_type_id: event_type_id
      )

      result = described_class.build(comment_form)

      expect(result.attribute_types).to match(
        'foo_bar' => instance_of(ActiveModel::Type::String),
        'bäß' => instance_of(ActiveModel::Type::String)
      )
    end

    it 'uses uses boolean type for attribute that represents a checkbox field' do
      event_type_id = 42
      comment_form = CommentForm.new(
        [
          CommentFormField.new(
            name: 'Foo Bar',
            type: 'checkbox',
            required: false,
            config: CommentFormField::Configuration.new
          )
        ],
        event_type_id: event_type_id
      )

      result = described_class.build(comment_form)

      expect(result.attribute_types['foo_bar']).to be_a(ActiveModel::Type::Boolean)
    end

    it 'uses uses boolean type for attribute that represents a checkbox field' do
      event_type_id = 42
      comment_form = CommentForm.new(
        [
          CommentFormField.new(
            name: 'Foo Bar',
            type: 'checkbox',
            required: false,
            config: CommentFormField::Configuration.new
          )
        ],
        event_type_id: event_type_id
      )

      result = described_class.build(comment_form)

      expect(result.attribute_types['foo_bar']).to be_a(ActiveModel::Type::Boolean)
    end

    it 'uses uses date type for attribute that represents a date field' do
      event_type_id = 42
      comment_form = CommentForm.new(
        [
          CommentFormField.new(
            name: 'Foo Bar',
            type: 'date',
            required: false,
            config: CommentFormField::Configuration.new
          )
        ],
        event_type_id: event_type_id
      )

      result = described_class.build(comment_form)

      expect(result.attribute_types['foo_bar']).to be_a(ActiveModel::Type::Date)
    end

    it 'uses uses time type for attribute that represents a time field' do
      event_type_id = 42
      comment_form = CommentForm.new(
        [
          CommentFormField.new(
            name: 'Foo Bar',
            type: 'time',
            required: false,
            config: CommentFormField::Configuration.new
          )
        ],
        event_type_id: event_type_id
      )

      result = described_class.build(comment_form)

      expect(result.attribute_types['foo_bar']).to be_a(ActiveModel::Type::Time)
    end

    it 'uses uses time type for attribute that represents a duration field' do
      event_type_id = 42
      comment_form = CommentForm.new(
        [
          CommentFormField.new(
            name: 'Foo Bar',
            type: 'duration',
            required: false,
            config: CommentFormField::Configuration.new
          )
        ],
        event_type_id: event_type_id
      )

      result = described_class.build(comment_form)

      expect(result.attribute_types['foo_bar']).to be_a(ActiveModel::Type::Time)
    end

    it 'accepts only valid values for combo items' do
      event_type_id = 42
      comment_form = CommentForm.new(
        [
          CommentFormField.new(
            name: 'Foo Bar',
            type: 'combo',
            required: false,
            config: CommentFormField::Configuration.new(values: %w[foo bar baz])
          )
        ],
        event_type_id: event_type_id
      )
      result = described_class.build(comment_form)
      instance = result.new

      instance.foo_bar = 'abc'
      expect(instance.foo_bar).to be_nil

      instance.foo_bar = 'bar'
      expect(instance.foo_bar).to eq('bar')
    end

    it 'accetps arrays excluding disallowed values for multi-combo items' do
      event_type_id = 42
      comment_form = CommentForm.new(
        [
          CommentFormField.new(
            name: 'Foo Bar',
            type: 'combo',
            required: false,
            config: CommentFormField::Configuration.new(multi: true, values: %w[foo bar baz])
          )
        ],
        event_type_id: event_type_id
      )
      result = described_class.build(comment_form)
      instance = result.new

      instance.foo_bar = %w[foo def bar]
      expect(instance.foo_bar).to eq(%w[foo bar])
    end

    it 'returns a model with presence validations for all required fields' do
      event_type_id = 42
      comment_form = CommentForm.new(
        [
          CommentFormField.new(
            name: 'Foo Bar',
            type: 'text',
            required: true,
            config: CommentFormField::Configuration.new
          ),
          CommentFormField.new(
            name: 'Bäß',
            type: 'text',
            required: false,
            config: CommentFormField::Configuration.new
          )
        ],
        event_type_id: event_type_id
      )

      result = described_class.build(comment_form)
      instance = result.new

      expect(instance).not_to be_valid
      expect(instance.errors.keys).to eq([:foo_bar])

      instance.foo_bar = 'foo'

      expect(instance).to be_valid
    end

    it 'memoizes the model by a comment form' do
      event_type_id = 42
      comment_form_first = CommentForm.new(
        [
          CommentFormField.new(
            name: 'Foo Bar',
            type: 'text',
            required: true,
            config: CommentFormField::Configuration.new
          ),
          CommentFormField.new(
            name: 'Bäß',
            type: 'text',
            required: false,
            config: CommentFormField::Configuration.new
          )
        ],
        event_type_id: event_type_id
      )
      comment_form_second = CommentForm.new(
        [
          CommentFormField.new(
            name: 'Foo Bar',
            type: 'text',
            required: true,
            config: CommentFormField::Configuration.new
          ),
          CommentFormField.new(
            name: 'Bäß',
            type: 'text',
            required: false,
            config: CommentFormField::Configuration.new
          )
        ],
        event_type_id: event_type_id
      )

      first = described_class.build(comment_form_first)
      second = described_class.build(comment_form_second)

      expect(first).to equal(second)
    end

    it 'does not use the memoized form if the shape of it changes' do
      event_type_id = 42
      comment_form_first = CommentForm.new(
        [
          CommentFormField.new(
            name: 'Foo Bar',
            type: 'text',
            required: true,
            config: CommentFormField::Configuration.new
          ),
          CommentFormField.new(
            name: 'Bäß',
            type: 'text',
            required: false,
            config: CommentFormField::Configuration.new
          )
        ],
        event_type_id: event_type_id
      )
      comment_form_second_changed = CommentForm.new(
        [
          CommentFormField.new(
            name: 'Foo Bar',
            type: 'text',
            required: true,
            config: CommentFormField::Configuration.new
          ),
          CommentFormField.new(
            name: 'Bäß',
            type: 'text',
            required: true,
            config: CommentFormField::Configuration.new
          )
        ],
        event_type_id: event_type_id
      )

      first = described_class.build(comment_form_first)
      second = described_class.build(comment_form_second_changed)

      expect(first).not_to equal(second)
    end
  end

  describe 'model#to_hash' do
    it 'returns a hash of values indexed by field names' do
      event_type_id = 42
      comment_form = CommentForm.new(
        [
          CommentFormField.new(
            name: 'Foo Bar',
            type: 'text',
            required: true,
            config: CommentFormField::Configuration.new
          ),
          CommentFormField.new(
            name: 'Bäß',
            type: 'text',
            required: false,
            config: CommentFormField::Configuration.new
          )
        ],
        event_type_id: event_type_id
      )
      subject = described_class.build(comment_form).new
      subject.foo_bar = 'buzz lightyear'
      subject.bäß = nil # rubocop:disable Naming/AsciiIdentifiers

      result = subject.to_hash

      expect(result).to eq('Foo Bar' => 'buzz lightyear', 'Bäß' => nil)
    end

    it 'returns a string of values joined with commas for a multi-combo' do
      event_type_id = 42
      comment_form = CommentForm.new(
        [
          CommentFormField.new(
            name: 'Foo Bar',
            type: 'combo',
            required: true,
            config: CommentFormField::Configuration.new(multi: true, values: %w[Yes No Maybe Undecided])
          )
        ],
        event_type_id: event_type_id
      )
      subject = described_class.build(comment_form).new
      subject.foo_bar = %w[Maybe Undecided]
      result = subject.to_hash

      expect(result).to eq('Foo Bar' => 'Maybe, Undecided')
    end
  end

  describe 'model#simple_form_field_options' do
    let(:event_type_id) { 42 }
    let(:comment_form) { CommentForm.new([field], event_type_id: event_type_id) }
    let(:model) { described_class.build(comment_form) }
    let(:instance) { model.new }
    subject(:result) { instance.simple_form_field_options(instance.attributes.keys.first) }

    describe 'for textfield' do
      let(:field) {
        CommentFormField.new(
          name: 'Foo Bär', type: 'textfield', required: true, config: CommentFormField::Configuration.new
        )
      }

      it { is_expected.to match(as: :string, label: 'Foo Bär', label_text: an_instance_of(Proc)) }
    end

    describe 'for textarea' do
      let(:field) {
        CommentFormField.new(
          name: 'Foo Bär', type: 'textarea', required: true, config: CommentFormField::Configuration.new
        )
      }

      it { is_expected.to match(as: :text, label: 'Foo Bär', label_text: an_instance_of(Proc)) }
    end

    describe 'for date' do
      let(:field) {
        CommentFormField.new(
          name: 'Foo Bär', type: 'date', required: true, config: CommentFormField::Configuration.new
        )
      }

      it { is_expected.to match(as: :date, label: 'Foo Bär', html5: true, label_text: an_instance_of(Proc)) }
    end

    describe 'for time' do
      let(:field) {
        CommentFormField.new(
          name: 'Foo Bär', type: 'time', required: true, config: CommentFormField::Configuration.new
        )
      }

      it { is_expected.to match(as: :time, label: 'Foo Bär', html5: true, label_text: an_instance_of(Proc)) }
    end

    describe 'for duration' do
      let(:field) {
        CommentFormField.new(
          name: 'Foo Bär', type: 'duration', required: true, config: CommentFormField::Configuration.new
        )
      }

      it { is_expected.to match(as: :time, label: 'Foo Bär', html5: true, label_text: an_instance_of(Proc)) }
    end

    describe 'for combo' do
      let(:field) {
        CommentFormField.new(
          name: 'Foo Bär', type: 'combo', required: true,
          config: CommentFormField::Configuration.new(values: %w[Yes No Maybe], empty_text: 'Pick carefully')
        )
      }

      it { is_expected.to match(as: :select, label: 'Foo Bär', collection: %w[Yes No Maybe], label_text: an_instance_of(Proc)) }
    end

    describe 'for combo (multi)' do
      let(:field) {
        CommentFormField.new(
          name: 'Foo Bär', type: 'combo', required: true,
          config: CommentFormField::Configuration.new(
            values: %w[Yes No Maybe],
            empty_text: 'Pick carefully',
            multi: true
          )
        )
      }

      it { is_expected.to match(as: :check_boxes, label: 'Foo Bär', collection: %w[Yes No Maybe], label_text: an_instance_of(Proc)) }
    end

    describe 'for checkbox' do
      context 'required' do
        let(:field) {
          CommentFormField.new(
            name: 'Foo Bär', type: 'checkbox', required: true, config: CommentFormField::Configuration.new
          )
        }

        it { is_expected.to match(as: :radio_buttons, collection: [['Yes', true], ['No', false]], label: 'Foo Bär', label_text: an_instance_of(Proc), required: true) }
      end

      context 'not required' do
        let(:field) {
          CommentFormField.new(
            name: 'Foo Bär', type: 'checkbox', required: false, config: CommentFormField::Configuration.new
          )
        }

        it { is_expected.to match(as: :radio_buttons, collection: [['Yes', true], ['No', false]], label: 'Foo Bär', label_text: an_instance_of(Proc), required: false) }
      end
    end

    describe 'for any other field' do
      let(:field) {
        CommentFormField.new(
          name: 'Foo Bär', type: 'foobar', required: true,
          config: CommentFormField::Configuration.new(empty_text: 'foo bar, baz?')
        )
      }

      it { is_expected.to match(as: :string, label: 'Foo Bär', placeholder: 'foo bar, baz?', label_text: an_instance_of(Proc)) }
    end
  end
end
