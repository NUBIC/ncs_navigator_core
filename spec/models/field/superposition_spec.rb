# -*- coding: utf-8 -*-

require 'spec_helper'
require 'set'

require File.expand_path('../be_adapted_matcher', __FILE__)
require File.expand_path('../superposition_with_test_data', __FILE__)

module Field
  # This spec relies very heavily on values in the following files:
  #
  # spec/fixtures/field/original_data.json
  # spec/fixtures/field/proposed_data.json
  # spec/models/field/superposition_with_test_data.rb
  #
  # You may want to have those files on hand whilst you read through this
  # spec.
  describe Superposition do
    include_context 'superposition with test data'

    let(:sp) { superposition }

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
          sp.send(collection)[entity_id][state].should == expected
        end

        it "sets ancestry" do
          expected = Hash[*ancestry.map { |k, ptr| [k, dereference(ptr, source)] }.flatten]
          actual = sp.send(collection)[entity_id][state].ancestors

          actual.should include(expected)
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

    describe '#set_current', :needs_superposition_current_data do
      it 'resolves contacts' do
        sp.contacts[contact_id][:current].should be_adapted(contact)
      end

      it 'resolves events' do
        sp.events[event_id][:current].should be_adapted(event)
      end

      it 'resolves instruments' do
        sp.instruments[instrument_id][:current].should be_adapted(instrument)
      end

      it 'resolves participants' do
        sp.participants[participant_id][:current].should be_adapted(participant)
      end

      it 'resolves persons' do
        sp.people[person_id][:current].should be_adapted(person)
      end

      it 'resolves response sets' do
        sp.response_sets[response_set_id][:current].should be_adapted(response_set)
      end

      it 'resolves responses' do
        sp.responses[response_id][:current].should be_adapted(response)
      end
    end

    describe '#build_question_response_sets' do
      include Field::Adoption

      let(:q1) { Factory(:question) }
      let(:q2) { Factory(:question) }
      let(:a) { Factory(:answer) }

      let(:hr1) { adapt_hash(:response, 'question_id' => q1.api_id) }
      let(:mr1) { adapt_model(Response.new(:question => q1, :answer => a)) }
      let(:hr1b) { adapt_hash(:response, 'question_id' => q1.api_id) }
      let(:mr1b) { adapt_model(Response.new(:question => q1, :answer => a)) }
      let(:hr2) { adapt_hash(:response, 'question_id' => q2.api_id) }
      let(:mr2) { adapt_model(Response.new(:question => q2, :answer => a)) }

      before do
        sp.responses = {
          'foo' => {
            :current => hr1,
            :original => mr1,
            :proposed => hr1
          },
          'bar' => {
            :current => hr1b,
            :original => mr1b,
            :proposed => hr1b
          },
          'baz' => {
            :current => hr2,
            :original => mr2,
            :proposed => hr2
          }
        }
      end

      QRS = Field::QuestionResponseSet

      it 'groups responses by question ID' do
        sp.build_question_response_sets

        sp.question_response_sets.should == {
          q1.api_id => {
            :current =>  QRS.new(hr1, hr1b),
            :original => QRS.new(mr1, mr1b),
            :proposed => QRS.new(hr1, hr1b)
          },
          q2.api_id => {
            :current =>  QRS.new(hr2),
            :original => QRS.new(mr2),
            :proposed => QRS.new(hr2)
          }
        }
      end
    end

    describe '#current_events', :needs_superposition_current_data do
      it 'returns events in the current set' do
        sp.current_events.should == [event]
      end
    end

    describe '#current_instruments', :needs_superposition_current_data do
      it 'returns instruments in the current set' do
        sp.current_instruments.should == [instrument]
      end
    end

    describe '#current_participants', :needs_superposition_current_data do
      it 'returns participants in the current set' do
        sp.current_participants.should == [participant]
      end
    end
  end
end
