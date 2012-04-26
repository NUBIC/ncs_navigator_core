# -*- coding: utf-8 -*-

require 'spec_helper'

require 'set'

module NcsNavigator::Core::Fieldwork
  describe Superposition do
    subject { Superposition.new }

    ##
    # See this file for referenced IDs...
    let(:original_data) { File.read("#{Rails.root}/spec/fixtures/field/original_data.json") }
    let(:original_json) { JSON.parse(original_data) }

    ##
    # ...and this file, too.
    let(:proposed_data) { File.read("#{Rails.root}/spec/fixtures/field/proposed_data.json") }
    let(:proposed_json) { JSON.parse(proposed_data) }

    # Commonly used UUIDs.
    let(:contact_id) { 'dc2a6c42-3b01-4c91-9e27-104c5aa3ef49' }
    let(:event_id) { 'bce1e030-34d3-012f-c157-58b035fb69ca' }
    let(:instrument_id) { 'c41f14e0-356c-012f-c15d-58b035fb69ca' }
    let(:participant_id) { 'f7b1da00-34d2-012f-c14b-58b035fb69ca' }
    let(:person_id) { 'f76a39d0-34d2-012f-c14a-58b035fb69ca' }
    let(:response_id) { 'e8661d8d-7bde-4a4d-bb79-6d807f4d3bf3' }
    let(:response_set_id) { '266ad829-f5d8-4df0-b821-3d33bb95be08' }

    def load_original
      subject.set_original(original_json)
    end

    def load_proposed
      subject.set_proposed(proposed_json)
    end

    describe 'for contacts' do
      describe '#set_original' do
        it 'sets the original state of all contacts' do
          load_original

          subject.contacts[contact_id][:original].should == original_json['contacts'][0]
        end
      end

      describe '#set_proposed' do
        it 'sets the proposed state of all contacts' do
          load_proposed

          subject.contacts[contact_id][:proposed].should == proposed_json['contacts'][0]
        end
      end
    end

    describe 'for events' do
      describe '#set_original' do
        it 'sets the original state of all events' do
          load_original

          subject.events[event_id][:original].should == original_json['contacts'][0]['events'][0]
        end
      end

      describe '#set_proposed' do
        it 'sets the proposed state of all events' do
          load_proposed

          subject.events[event_id][:proposed].should == proposed_json['contacts'][0]['events'][0]
        end
      end
    end

    describe 'for instruments' do
      describe '#set_original' do
        it 'sets the original state of all instruments' do
          load_original

          subject.instruments[instrument_id][:original].should ==
            original_json['contacts'][0]['events'][0]['instruments'][0]
        end
      end

      describe '#set_proposed' do
        it 'sets the proposed state of all instruments' do
          load_proposed

          subject.instruments[instrument_id][:proposed].should ==
            proposed_json['contacts'][0]['events'][0]['instruments'][0]
        end
      end
    end

    describe 'for participants' do
      describe '#set_original' do
        it 'sets the original state of all participants' do
          load_original

          subject.participants[participant_id][:original].should ==
            original_json['participants'][0]
        end
      end

      describe '#set_proposed' do
        it 'sets the proposed state of all participants' do
          load_proposed

          subject.participants[participant_id][:proposed].should ==
            proposed_json['participants'][0]
        end
      end
    end

    describe 'for people' do
      describe '#set_original' do
        it 'sets the original state of all people' do
          load_original

          subject.people[person_id][:original].should ==
            original_json['participants'][0]['persons'][0]
        end
      end

      describe '#set_proposed' do
        it 'sets the proposed state of all people' do
          load_proposed

          subject.people[person_id][:proposed].should ==
            proposed_json['participants'][0]['persons'][0]
        end
      end
    end

    describe 'for response sets' do
      describe '#set_original' do
        it 'sets the original state of all response sets' do
          load_original

          subject.response_sets[response_set_id][:original].should ==
            original_json['contacts'][0]['events'][0]['instruments'][0]['response_set']
        end
      end

      describe '#set_proposed' do
        it 'sets the proposed state of all response sets' do
          load_proposed

          subject.response_sets[response_set_id][:proposed].should ==
            proposed_json['contacts'][0]['events'][0]['instruments'][0]['response_set']
        end
      end
    end

    describe 'for responses' do
      describe '#set_original' do
        it 'sets the original state of all responses' do
          load_original

          subject.responses[response_id][:original].should ==
            original_json['contacts'][0]['events'][0]['instruments'][0]['response_set']['responses'][0]
        end
      end

      describe '#set_proposed' do
        it 'sets the proposed state of all responses' do
          load_proposed

          subject.responses[response_id][:proposed].should ==
            proposed_json['contacts'][0]['events'][0]['instruments'][0]['response_set']['responses'][0]
        end
      end
    end

    describe '#resolve_current' do
      let!(:contact) { Factory(:contact, :contact_id => contact_id) }
      let!(:event) { Factory(:event, :event_id => event_id) }
      let!(:instrument) { Factory(:instrument, :instrument_id => instrument_id) }
      let!(:participant) { Factory(:participant, :p_id => participant_id) }
      let!(:person) { Factory(:person, :person_id => person_id) }
      let!(:q) { Factory(:question) }
      let!(:a) { Factory(:answer) }
      let!(:response) { Factory(:response, :api_id => response_id, :question => q, :answer => a) }
      let!(:response_set) { Factory(:response_set, :api_id => response_set_id) }

      before do
        load_original
        load_proposed

        subject.resolve_current
      end

      it 'resolves contacts' do
        subject.contacts[contact_id][:current].should == contact
      end

      it 'resolves events' do
        subject.events[event_id][:current].should == event
      end

      it 'resolves instruments' do
        subject.instruments[instrument_id][:current].should == instrument
      end

      it 'resolves participants' do
        subject.participants[participant_id][:current].should == participant
      end

      it 'resolves persons' do
        subject.people[person_id][:current].should == person
      end

      it 'resolves response sets' do
        subject.response_sets[response_set_id][:current].should == response_set
      end

      it 'resolves responses' do
        subject.responses[response_id][:current].should == response
      end
    end
  end
end