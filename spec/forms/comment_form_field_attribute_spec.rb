# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommentFormFieldAttribute do
  describe '#name' do
    it 'will be underscore-ized lowercase representation of the field name' do
      comment_form_field = CommentFormField.new(
        name: 'Foo Bar Bäß',
        type: 'text',
        required: false,
        config: CommentFormField::Configuration.new
      )

      subject = described_class.new(comment_form_field)

      expect(subject.name).to eq('foo_bar_bäß')
    end
  end

  describe '#type' do
    let(:comment_form_field_type) { nil }
    let(:comment_form_field_configuration) { CommentFormField::Configuration.new }
    let(:comment_form_field) {
      CommentFormField.new(
        name: 'Foo Bar',
        type: comment_form_field_type,
        required: false,
        config: comment_form_field_configuration
      )
    }
    let(:instance) { described_class.new(comment_form_field) }
    subject(:type) { instance.type }

    context 'for type of comment form field "checkbox"' do
      let(:comment_form_field_type) { 'checkbox' }

      it { is_expected.to eq(:boolean) }
    end

    context 'for type of comment form field "date"' do
      let(:comment_form_field_type) { 'date' }

      it { is_expected.to eq(:date) }
    end

    context 'for type of comment form field "time"' do
      let(:comment_form_field_type) { 'time' }

      it { is_expected.to eq(:time) }
    end

    context 'for type of comment form field "duration"' do
      let(:comment_form_field_type) { 'duration' }

      it { is_expected.to eq(:time) }
    end

    context 'for type of comment form field "combo"' do
      let(:comment_form_field_type) { 'combo' }

      context 'when multiple values are allowed' do
        let(:comment_form_field_configuration) { CommentFormField::Configuration.new(multi: true) }

        it { is_expected.to be_a(described_class::MultiComboType) }
      end

      context 'when multiple values are not allowed' do
        let(:comment_form_field_configuration) { CommentFormField::Configuration.new }

        it { is_expected.to be_a(described_class::ComboType) }
      end
    end

    context 'for type of comment form field "text"' do
      let(:comment_form_field_type) { 'text' }

      it { is_expected.to eq(:string) }
    end
  end

  describe '#required?' do
    let(:comment_form_field_required) { nil }
    let(:comment_form_field) {
      CommentFormField.new(
        name: 'Foo Bar',
        type: 'text',
        required: comment_form_field_required,
        config: CommentFormField::Configuration.new
      )
    }
    subject(:instance) { described_class.new(comment_form_field) }

    context 'comment form field is required' do
      let(:comment_form_field_required) { true }

      it { is_expected.to be_required }
    end

    context 'comment form field is not required' do
      let(:comment_form_field_required) { false }

      it { is_expected.not_to be_required }
    end
  end

  describe '#validation' do
    let(:comment_form_field_type) { nil }
    let(:comment_form_field_required) { nil }
    let(:comment_form_field) {
      CommentFormField.new(
        name: 'Foo Bar',
        type: comment_form_field_type,
        required: comment_form_field_required,
        config: CommentFormField::Configuration.new
      )
    }
    let(:instance) { described_class.new(comment_form_field) }
    subject(:type) { instance.validation }

    context 'when field is not required' do
      let(:comment_form_field_required) { false }
      let(:comment_form_field_type) { 'text' }

      it { is_expected.to be_nil }
    end

    context 'when field is a checkbox' do
      let(:comment_form_field_required) { true }
      let(:comment_form_field_type) { 'checkbox' }

      it { is_expected.to eq(acceptance: true, inclusion: { in: [true, false] }) }
    end

    context 'when field is anything but a checkbox' do
      let(:comment_form_field_required) { true }
      let(:comment_form_field_type) { 'text' }

      it { is_expected.to eq(presence: true) }
    end
  end
end
