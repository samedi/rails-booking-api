# frozen_string_literal: true

require 'comment_form_field'
require 'comment_form_field_api_mapper'

RSpec.describe CommentFormFieldAPIMapper do
  describe '#map_collection' do
    it 'returns an array of CommentFormField entities that matches the hashes provided' do
      list = [
        { 'name' => 'Vorerkrankungen', 'required' => true, 'type' => 'textfield', 'config' => nil },
        { 'name' => 'Adresse', 'required' => true, 'type' => 'textarea', 'config' => nil }
      ]
      subject = described_class.new

      first, second = subject.map_collection(list)

      expect(first.name).to eq('Vorerkrankungen')
      expect(second.name).to eq('Adresse')
    end
  end

  describe '#map_single' do
    it 'returns CommentFormField that matches a textfield' do
      hash = {
        'name' => 'Vorerkrankungen',
        'required' => true,
        'type' => 'textfield',
        'config' => nil
      }
      subject = described_class.new

      result = subject.map_single(hash)

      expect(result.name).to eq('Vorerkrankungen')
      expect(result).to be_required
      expect(result.type).to eq('textfield')
      expect(result.config.restriction).to be_nil
      expect(result.config.values).to be_nil
      expect(result.config.empty_text).to be_nil
      expect(result.config).not_to be_multi
    end

    it 'returns CommentFormField that matches a textarea' do
      hash = {
        'name' => 'Adresse',
        'required' => true,
        'type' => 'textarea',
        'config' => nil
      }
      subject = described_class.new

      result = subject.map_single(hash)

      expect(result.name).to eq('Adresse')
      expect(result).to be_required
      expect(result.type).to eq('textarea')
      expect(result.config).not_to be_nil
    end

    it 'returns CommentFormField that matches a datepicker' do
      hash = {
        'name' => 'Wann beginnt die Reise?',
        'required' => true,
        'type' => 'date',
        'config' => nil
      }
      subject = described_class.new

      result = subject.map_single(hash)

      expect(result.name).to eq('Wann beginnt die Reise?')
      expect(result).to be_required
      expect(result.type).to eq('date')
      expect(result.config).not_to be_nil
    end

    # Couldn't find an example of a date field with configuration in production
    it 'returns CommentFormField that matches a datepicker with restrictions' do
      hash = {
        'name' => 'Wann beginnt die Reise?',
        'required' => true,
        'type' => 'date',
        'config' => { 'restriction' => 'future' }
      }
      subject = described_class.new

      result = subject.map_single(hash)

      expect(result.name).to eq('Wann beginnt die Reise?')
      expect(result).to be_required
      expect(result.type).to eq('date')
      expect(result.config.restriction).to eq('future')
    end

    it 'returns CommentFormField that matches a timepicker' do
      hash = {
        'name' => 'Dauer',
        'required' => false,
        'type' => 'time',
        'config' => nil
      }
      subject = described_class.new

      result = subject.map_single(hash)

      expect(result.name).to eq('Dauer')
      expect(result).not_to be_required
      expect(result.type).to eq('time')
      expect(result.config).not_to be_nil
    end

    # Coulnd't find an example of duration field type
    it 'returns CommentFormField that matches a duration field' do
      hash = {
        'name' => 'Dauer',
        'required' => false,
        'type' => 'duration',
        'config' => nil
      }
      subject = described_class.new

      result = subject.map_single(hash)

      expect(result.name).to eq('Dauer')
      expect(result).not_to be_required
      expect(result.type).to eq('duration')
      expect(result.config).not_to be_nil
    end

    it 'returns CommentFormField that matches a combo field' do
      hash = {
        'name' => 'Sind sie aktuell Schwanger?',
        'required' => true,
        'type' => 'combo',
        'config' => {
          'values' => "ja\nnein",
          'emptyText' => 'Wenn ja, welche Woche?'
        }
      }
      subject = described_class.new

      result = subject.map_single(hash)

      expect(result.name).to eq('Sind sie aktuell Schwanger?')
      expect(result).to be_required
      expect(result.type).to eq('combo')
      expect(result.config.values).to eq(%w[ja nein])
      expect(result.config.empty_text).to eq('Wenn ja, welche Woche?')
      expect(result.config).not_to be_multi
    end

    it 'returns CommentFormField that matches a combo field with multiple choice' do
      hash = {
        'name' => 'Impfung',
        'required' => false,
        'type' => 'combo',
        'config' => {
          'values' => "Tetanus\nDiphtherie\nKeuchhusten (Pertussis)\nKinderlähmung (Polio)\nPneumokokken\nMasern, Mumps, Röteln (MMR)\nWindpocken (Varizellen)\nGrippe (Influenza)\nHumane Papillomaviren (HPV)\nReiseimpfungen nach Vorabsprache\nFSME",
          'multi' => 'on',
          'emptyText' => ''
        }
      }
      subject = described_class.new

      result = subject.map_single(hash)

      expect(result.name).to eq('Impfung')
      expect(result).not_to be_required
      expect(result.type).to eq('combo')
      expect(result.config.values).to eq(
        [
          'Tetanus', 'Diphtherie', 'Keuchhusten (Pertussis)', 'Kinderlähmung (Polio)',
          'Pneumokokken', 'Masern, Mumps, Röteln (MMR)', 'Windpocken (Varizellen)', 'Grippe (Influenza)',
          'Humane Papillomaviren (HPV)', 'Reiseimpfungen nach Vorabsprache', 'FSME'
        ]
      )
      expect(result.config.empty_text).to be_empty
      expect(result.config).to be_multi
    end

    it 'returns CommentFormField that matches a checkbox field' do
      hash = {
        'name' => 'Ich bringe meinen Personalausweis zur Identifizierung mit zum Termin!',
        'required' => true,
        'type' => 'checkbox',
        'config' => nil
      }
      subject = described_class.new

      result = subject.map_single(hash)

      expect(result.name).to eq('Ich bringe meinen Personalausweis zur Identifizierung mit zum Termin!')
      expect(result).to be_required
      expect(result.type).to eq('checkbox')
      expect(result.config).not_to be_nil
    end

    # Used in one of demo/testing clinics, should not appear in normal usage
    it 'returns CommentFormField that passes any arbitrary type' do
      hash = {
        'name' => 'ICD10-Diagnose',
        'required' => false,
        'type' => 'icd10',
        'config' => {
          'emptyText' => 'Wählen Sie eine Diagnose'
        }
      }
      subject = described_class.new

      result = subject.map_single(hash)

      expect(result.name).to eq('ICD10-Diagnose')
      expect(result).not_to be_required
      expect(result.type).to eq('icd10')
      expect(result.config.empty_text).to eq('Wählen Sie eine Diagnose')
    end
  end
end
