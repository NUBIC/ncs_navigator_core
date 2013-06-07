require 'spec_helper'

shared_context 'superposition with test data' do
  let(:superposition) { Field::Superposition.new }

  ##
  # See this file for referenced IDs...
  let(:original_data) { File.read("#{Rails.root}/spec/fixtures/field/original_data.json") }
  let(:original_json) { JSON.parse(original_data) }

  ##
  # ...and this file, too.
  let(:proposed_data) { File.read("#{Rails.root}/spec/fixtures/field/proposed_data.json") }
  let(:proposed_json) { JSON.parse(proposed_data) }

  # Commonly used UUIDs in the original and proposed datasets.
  let(:contact_id) { 'dc2a6c42-3b01-4c91-9e27-104c5aa3ef49' }
  let(:event_id) { 'bce1e030-34d3-012f-c157-58b035fb69ca' }
  let(:instrument_id) { 'c41f14e0-356c-012f-c15d-58b035fb69ca' }
  let(:participant_id) { 'f7b1da00-34d2-012f-c14b-58b035fb69ca' }
  let(:person_id) { 'f76a39d0-34d2-012f-c14a-58b035fb69ca' }
  let(:question_id) { '61387010-331b-012f-8a99-58b035fb69ca' }
  let(:response_id) { 'e8661d8d-7bde-4a4d-bb79-6d807f4d3bf3' }
  let(:response_set_id) { '266ad829-f5d8-4df0-b821-3d33bb95be08' }

  def load_original
    superposition.set_original(original_json)
  end

  def load_proposed
    superposition.set_proposed(proposed_json)
  end
end

shared_context 'current data for superposition', :needs_superposition_current_data do
  let!(:contact) { Factory(:contact, :contact_id => contact_id) }
  let!(:event) { Factory(:event, :event_id => event_id, :event_type_code => 13, :event_start_date => '2000-01-01') }
  let!(:instrument) { Factory(:instrument, :instrument_id => instrument_id) }
  let!(:participant) { Factory(:participant, :p_id => participant_id) }
  let!(:person) { Factory(:person, :person_id => person_id) }
  let!(:question) { Factory(:question) }
  let!(:answer) { Factory(:answer, :question => question) }
  let!(:response) { Factory(:response, :api_id => response_id, :question => question, :answer => answer) }
  let!(:response_set) { Factory(:response_set, :api_id => response_set_id) }

  before do
    load_original
    load_proposed
    superposition.set_current
  end
end
