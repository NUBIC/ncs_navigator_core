# -*- coding: utf-8 -*-

require 'spec_helper'
require 'set'

require File.expand_path('../be_adapted_matcher', __FILE__)

module Field
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
      subject.set_original(original_json)
    end

    def load_proposed
      subject.set_proposed(proposed_json)
    end

    def load_current
      subject.set_current
    end

    def dereference(ptr, doc)
      ptr.split('/')[1..-1].inject(doc) do |doc, cur|
        if cur.to_i.to_s == cur
          doc[cur.to_i]
        else
          doc[cur]
        end
      end
    end

    shared_examples_for 'an entity set' do |state, collection|
      describe "#set_#{state}" do
        before do
          eval("load_#{state}")
        end

        let(:source) { eval("#{state}_json") }
        let(:expected) { dereference(pointer, source) }
        let(:entity_id) { eval("#{collection.singularize}_id") }

        it "sets the #{state} state for #{collection}" do
          subject.send(collection)[entity_id][state].should == expected
        end

        it "sets ancestry" do
          dereferenced = Hash[*ancestry.map { |k, ptr| [k, dereference(ptr, source)] }.flatten]

          subject.send(collection)[entity_id][state].ancestors.should include(dereferenced)
        end
      end
    end

    describe 'for contacts' do
      let(:ancestry) do
        { :person_id => '/contacts/0/person_id' }
      end

      let(:pointer) { '/contacts/0' }

      it_should_behave_like 'an entity set', :original, 'contacts'
      it_should_behave_like 'an entity set', :proposed, 'contacts'
    end

    describe 'for events' do
      let(:ancestry) do
        { :contact => '/contacts/0' }
      end

      let(:pointer) { '/contacts/0/events/0' }

      it_should_behave_like 'an entity set', :original, 'events'
      it_should_behave_like 'an entity set', :proposed, 'events'
    end

    describe 'for instruments' do
      let(:ancestry) do
        { :contact => '/contacts/0',
          :event => '/contacts/0/events/0'
        }
      end

      let(:pointer) { '/contacts/0/events/0/instruments/0' }

      it_should_behave_like 'an entity set', :original, 'instruments'
      it_should_behave_like 'an entity set', :proposed, 'instruments'
    end

    describe 'for participants' do
      let(:ancestry) { {} }
      let(:pointer) { '/participants/0' }

      it_should_behave_like 'an entity set', :original, 'participants'
      it_should_behave_like 'an entity set', :proposed, 'participants'
    end

    describe 'for people' do
      let(:ancestry) do
        { :participant => '/participants/0' }
      end

      let(:pointer) { '/participants/0/persons/0' }

      it_should_behave_like 'an entity set', :original, 'people'
      it_should_behave_like 'an entity set', :proposed, 'people'
    end

    describe 'for response sets' do
      let(:ancestry) do
        { :instrument => '/contacts/0/events/0/instruments/0' }
      end

      let(:pointer) { '/contacts/0/events/0/instruments/0/response_sets/0' }

      it_should_behave_like 'an entity set', :original, 'response_sets'
      it_should_behave_like 'an entity set', :proposed, 'response_sets'
    end

    describe 'for responses' do
      let(:ancestry) do
        { :response_set => '/contacts/0/events/0/instruments/0/response_sets/0' }
      end

      let(:pointer) { '/contacts/0/events/0/instruments/0/response_sets/0/responses/0' }

      it_should_behave_like 'an entity set', :original, 'responses'
      it_should_behave_like 'an entity set', :proposed, 'responses'
    end

    shared_context 'current data' do
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
        load_current
      end
    end

    describe '#set_current' do
      include_context 'current data'

      it 'resolves contacts' do
        subject.contacts[contact_id][:current].should be_adapted(contact)
      end

      it 'resolves events' do
        subject.events[event_id][:current].should be_adapted(event)
      end

      it 'resolves instruments' do
        subject.instruments[instrument_id][:current].should be_adapted(instrument)
      end

      it 'resolves participants' do
        subject.participants[participant_id][:current].should be_adapted(participant)
      end

      it 'resolves persons' do
        subject.people[person_id][:current].should be_adapted(person)
      end

      it 'resolves response sets' do
        subject.response_sets[response_set_id][:current].should be_adapted(response_set)
      end

      it 'resolves responses' do
        subject.responses[response_id][:current].should be_adapted(response)
      end
    end

    describe '#current_events' do
      include_context 'current data'

      it 'returns events in the current set' do
        subject.current_events.should == [event]
      end
    end

    describe '#current_instruments' do
      include_context 'current data'

      it 'returns instruments in the current set' do
        subject.current_instruments.should == [instrument]
      end
    end

    describe '#current_participants' do
      include_context 'current data'

      it 'returns participants in the current set' do
        subject.current_participants.should == [participant]
      end
    end
  end
end
