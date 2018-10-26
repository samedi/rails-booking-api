# frozen_string_literal: true

require 'faraday'
require 'faraday_middleware'
require 'samedi'
require 'samedi/patient_api'
require 'samedi/patient_api/connection_provider'
require 'institution'
require 'fetch_institution_details'
require 'test_service_container'

RSpec.describe FetchInstitutionDetails do
  describe '#call' do
    it 'returns Institution with a name', vcr: { cassette_name: 'fetch_institution_details_success' } do
      institution_id = 'BCMNWE2W3N2R3Z4K'
      subject = described_class.new(connection_provider: TestServiceContainer.booking_connection_provider)

      result = subject.call(institution_id: institution_id)

      expect(result.name).to eq('Krankenkasse VM')
    end

    it 'raises InstitutionNotFound exception when institution_id does not exist', vcr: { cassette_name: 'fetch_institution_details_404' } do
      institution_id = '404_Institution_Not_Found'
      subject = described_class.new(connection_provider: TestServiceContainer.booking_connection_provider)

      expect {
        subject.call(institution_id: institution_id)
      }.to raise_error(FetchInstitutionDetails::InstitutionNotFound)
    end
  end
end
