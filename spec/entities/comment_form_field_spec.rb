# frozen_string_literal: true

require 'comment_form_field'

RSpec.describe CommentFormField do
  describe CommentFormField::Configuration do
    describe '#==' do
      specify '2 objects are equal when their restriction, value, empty_text, and multi are equal' do
        first = CommentFormField::Configuration.new(
          restriction: 'future', values: %w[abc def], empty_text: 'foo', multi: true
        )
        second = CommentFormField::Configuration.new(
          restriction: 'future', values: %w[abc def], empty_text: 'foo', multi: true
        )

        expect(first).to eq(second)
      end

      specify '2 objects are not equal when any of the attributes do not match' do
        first = CommentFormField::Configuration.new(
          restriction: 'future', values: %w[abc def], empty_text: 'foo', multi: true
        )
        different_restriction = CommentFormField::Configuration.new(
          restriction: 'past', values: %w[abc def], empty_text: 'foo', multi: true
        )
        different_values = CommentFormField::Configuration.new(
          restriction: 'future', values: ['def'], empty_text: 'foo', multi: true
        )
        different_empty_text = CommentFormField::Configuration.new(
          restriction: 'future', values: %w[abc def], empty_text: 'bar', multi: true
        )
        different_multi = CommentFormField::Configuration.new(
          restriction: 'future', values: %w[abc def], empty_text: 'foo', multi: false
        )

        expect(first).not_to eq(different_restriction)
        expect(first).not_to eq(different_values)
        expect(first).not_to eq(different_empty_text)
        expect(first).not_to eq(different_multi)
      end
    end

    describe 'hash' do
      specify '2 objects have same hash when their restriction, value, empty_text, and multi are equal' do
        first = CommentFormField::Configuration.new(
          restriction: 'future', values: %w[abc def], empty_text: 'foo', multi: true
        )
        second = CommentFormField::Configuration.new(
          restriction: 'future', values: %w[abc def], empty_text: 'foo', multi: true
        )

        expect(first.hash).to eq(second.hash)
      end

      specify '2 objects have different hashes when any of the attributes are different' do
        first = CommentFormField::Configuration.new(
          restriction: 'future', values: %w[abc def], empty_text: 'foo', multi: true
        )
        different_restriction = CommentFormField::Configuration.new(
          restriction: 'past', values: %w[abc def], empty_text: 'foo', multi: true
        )
        different_values = CommentFormField::Configuration.new(
          restriction: 'future', values: ['def'], empty_text: 'foo', multi: true
        )
        different_empty_text = CommentFormField::Configuration.new(
          restriction: 'future', values: %w[abc def], empty_text: 'bar', multi: true
        )
        different_multi = CommentFormField::Configuration.new(
          restriction: 'future', values: %w[abc def], empty_text: 'foo', multi: false
        )

        expect(first.hash).not_to eq(different_restriction.hash)
        expect(first.hash).not_to eq(different_values.hash)
        expect(first.hash).not_to eq(different_empty_text.hash)
        expect(first.hash).not_to eq(different_multi.hash)
      end
    end
  end

  describe '#==' do
    specify '2 fields are equal if their name, required, type, and config are same' do
      first = CommentFormField.new(
        name: 'Foo Bar', required: true, type: 'textfield', config: CommentFormField::Configuration.new
      )
      second = CommentFormField.new(
        name: 'Foo Bar', required: true, type: 'textfield', config: CommentFormField::Configuration.new
      )

      expect(first).to eq(second)
    end

    specify '2 fields are not equal if either their name, required, type, or config are different' do
      first = CommentFormField.new(
        name: 'Foo Bar', required: true, type: 'textfield', config: CommentFormField::Configuration.new
      )
      different_name = CommentFormField.new(
        name: 'Bar Baz', required: true, type: 'textfield', config: CommentFormField::Configuration.new
      )
      different_required = CommentFormField.new(
        name: 'Foo Bar', required: false, type: 'textfield', config: CommentFormField::Configuration.new
      )
      different_type = CommentFormField.new(
        name: 'Foo Bar', required: true, type: 'textarea', config: CommentFormField::Configuration.new
      )
      different_config = CommentFormField.new(
        name: 'Foo Bar', required: true, type: 'textfield',
        config: CommentFormField::Configuration.new(empty_text: '')
      )

      expect(first).not_to eq(different_name)
      expect(first).not_to eq(different_required)
      expect(first).not_to eq(different_type)
      expect(first).not_to eq(different_config)
    end
  end

  describe '#hash' do
    specify '2 fields have same hash if their name, required, type, and config are same' do
      first = CommentFormField.new(
        name: 'Foo Bar', required: true, type: 'textfield', config: CommentFormField::Configuration.new
      )
      second = CommentFormField.new(
        name: 'Foo Bar', required: true, type: 'textfield', config: CommentFormField::Configuration.new
      )

      expect(first.hash).to eq(second.hash)
    end

    specify '2 fields have different hashes if either their name, required, type, or config are different' do
      first = CommentFormField.new(
        name: 'Foo Bar', required: true, type: 'textfield', config: CommentFormField::Configuration.new
      )
      different_name = CommentFormField.new(
        name: 'Bar Baz', required: true, type: 'textfield', config: CommentFormField::Configuration.new
      )
      different_required = CommentFormField.new(
        name: 'Foo Bar', required: false, type: 'textfield', config: CommentFormField::Configuration.new
      )
      different_type = CommentFormField.new(
        name: 'Foo Bar', required: true, type: 'textarea', config: CommentFormField::Configuration.new
      )
      different_config = CommentFormField.new(
        name: 'Foo Bar', required: true, type: 'textfield',
        config: CommentFormField::Configuration.new(empty_text: '')
      )

      expect(first.hash).not_to eq(different_name.hash)
      expect(first.hash).not_to eq(different_required.hash)
      expect(first.hash).not_to eq(different_type.hash)
      expect(first.hash).not_to eq(different_config.hash)
    end
  end
end
