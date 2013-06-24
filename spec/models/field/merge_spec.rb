# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: merges
#
#  client_id       :string(255)
#  conflict_report :text
#  crashed_at      :datetime
#  created_at      :datetime
#  fieldwork_id    :integer
#  id              :integer          not null, primary key
#  log             :text
#  merged_at       :datetime
#  proposed_data   :text
#  staff_id        :string(255)
#  started_at      :datetime
#  synced_at       :datetime
#  updated_at      :datetime
#  username        :string(255)      not null
#

require 'spec_helper'

require 'stringio'
require 'json'

require File.expand_path('../shared_merge_behaviors', __FILE__)

module Field
  describe Merge do
    subject do
      Class.new(Superposition) do
        include Merge
      end.new
    end

    def self.it_merges(property)
      describe "##{property}" do
        properties << property

        it_behaves_like 'an attribute merge', entity, property do
          let(:vessel) { subject }
        end
      end
    end

    def self.when_merging(entity, &block)
      describe "on #{entity}" do
        include MergeValueGeneration

        cattr_accessor :entity
        cattr_accessor :properties

        self.entity = entity
        self.properties = []

        it_behaves_like 'an entity merge', entity do
          let(:vessel) { subject }
        end

        instance_eval(&block)
      end
    end

    when_merging 'Contact' do
      it_merges 'contact_date_date'
      it_merges 'contact_disposition'
      it_merges 'contact_distance'
      it_merges 'contact_end_time'
      it_merges 'contact_interpret_code'
      it_merges 'contact_interpret_other'
      it_merges 'contact_language_code'
      it_merges 'contact_language_other'
      it_merges 'contact_location_code'
      it_merges 'contact_location_other'
      it_merges 'contact_private_code'
      it_merges 'contact_private_detail'
      it_merges 'contact_start_time'
      it_merges 'contact_type_code'
      it_merges 'who_contacted_code'
      it_merges 'who_contacted_other'
    end

    when_merging 'Event' do
      it_merges 'event_breakoff_code'
      it_merges 'event_comment'
      it_merges 'event_disposition'
      it_merges 'event_disposition_category_code'
      it_merges 'event_end_date'
      it_merges 'event_end_time'
      it_merges 'event_incentive_type_code'
      it_merges 'event_incentive_cash'
      it_merges 'event_repeat_key'
      it_merges 'event_start_date'
      it_merges 'event_start_time'
      it_merges 'event_type_code'
      it_merges 'event_type_other'
    end

    when_merging 'Instrument' do
      it_merges 'instrument_breakoff_code'
      it_merges 'instrument_comment'
      it_merges 'data_problem_code'
      it_merges 'instrument_end_date'
      it_merges 'instrument_end_time'
      it_merges 'instrument_method_code'
      it_merges 'instrument_mode_code'
      it_merges 'instrument_mode_other'
      it_merges 'instrument_repeat_key'
      it_merges 'instrument_start_date'
      it_merges 'instrument_start_time'
      it_merges 'instrument_status_code'
      it_merges 'supervisor_review_code'
      it_merges 'instrument_type_code'
      it_merges 'instrument_type_other'
      it_merges 'instrument_version'
    end

    when_merging 'ResponseSet' do
      it_merges 'completed_at'
    end

    when_merging 'Person' do
      it_merges 'first_name'
      it_merges 'last_name'
      it_merges 'middle_name'
      it_merges 'prefix_code'
      it_merges 'suffix_code'
    end

    describe 'when merging QuestionResponseSets' do
      before do
        test_set = {
          uuid => { :original => o, :current => c, :proposed => p }
        }

        subject.question_response_sets = test_set
      end

      let(:conflicts) { subject.conflicts }
      let(:set) { subject.question_response_sets.values.first }
      let(:uuid) { 'foo' }
      let(:q) { Factory(:question) }
      let(:a) { Factory(:answer, :question => q) }
      let(:a2) { Factory(:answer, :question => q) }
      let(:a3) { Factory(:answer, :question => q) }

      def new_qrs(*responses)
        Field::QuestionResponseSet.new(*responses)
      end

      def create_response_model
        Factory(:response, :question => q, :answer => a)
      end

      def merge
        subject.merge
      end

      describe 'for sets O, C, P' do
        include Field::Adoption

        describe 'if O = C = P = nil' do
          let(:o) { nil }
          let(:c) { nil }
          let(:p) { nil }

          it 'leaves C at nil' do
            merge

            set[:current].should be_nil
          end
        end

        describe 'if O = C = nil and P is new' do
          let(:o) { nil }
          let(:c) { nil }
          let(:p) { new_qrs(adapt_hash(:response, {})) }

          it 'copies P to C' do
            merge

            set[:current].should == p.to_model
          end
        end

        describe 'if O = P = nil and C exists' do
          let(:o) { nil }
          let(:c) { new_qrs(adapt_model(create_response_model)) }
          let(:p) { nil }

          it 'does not modify C' do
            merge

            set[:current].should_not be_changed
          end
        end

        describe 'if C = P = nil and O exists' do
          let(:o) { new_qrs(adapt_model(create_response_model)) }
          let(:c) { nil }
          let(:p) { nil }

          it 'leaves C at nil' do
            merge

            set[:current].should be_nil
          end
        end

        describe 'if O exists, C is nil, and P is new' do
          let(:o) { new_qrs(adapt_model(create_response_model)) }
          let(:c) { nil }
          let(:p) { new_qrs(adapt_hash(:response, {})) }

          it 'signals a conflict' do
            merge

            conflicts.should == {
              'QuestionResponseSet' => { uuid => { :self => { 'original' => o, 'current' => c, 'proposed' => p } } }
            }
          end

          it 'leaves C at nil' do
            set[:current].should be_nil
          end
        end

        describe 'if O exists, C exists, and P is nil' do
          let(:o) { new_qrs(adapt_model(create_response_model)) }
          let(:c) { new_qrs(adapt_model(create_response_model)) }
          let(:p) { nil }

          it 'does not modify C' do
            merge

            set[:current].should_not be_changed
          end
        end

        describe 'if O = nil, C = P' do
          let(:o) { nil }
          let(:c) { new_qrs(adapt_model(Response.new(:question => q, :answer => a))) }
          let(:p) { new_qrs(adapt_hash(:response, { 'question_id' => q.api_id, 'answer_id' => a.api_id })) }

          it 'does not modify C' do
            merge

            set[:current].should_not be_changed
          end
        end

        describe 'if O = nil, C != P' do
          let(:o) { nil }
          let(:c) { new_qrs(adapt_model(Response.new(:question => q, :answer => a))) }
          let(:p) { new_qrs(adapt_hash(:response, { })) }

          it 'signals a conflict' do
            merge

            conflicts.should == {
              'QuestionResponseSet' => { uuid => { :self => { 'original' => o, 'current' => c, 'proposed' => p } } }
            }
          end
        end

        describe 'if O = C != P' do
          let(:o) { new_qrs(adapt_model(Response.new(:question => q, :answer => a))) }
          let(:c) { new_qrs(adapt_model(Response.new(:question => q, :answer => a))) }
          let(:p) { new_qrs(adapt_hash(:response, { 'question_id' => q.api_id, 'value' => 'foo' })) }

          it 'patches C with P' do
            merge

            set[:current].should be_changed
          end
        end

        describe 'if O = P, C != P' do
          let(:o) { new_qrs(adapt_model(Response.new(:question => q, :answer => a))) }
          let(:c) { new_qrs(adapt_model(Response.new(:question => q, :answer => a2))) }
          let(:p) { new_qrs(adapt_hash(:response, { 'question_id' => q.api_id, 'answer_id' => a.api_id })) }

          it 'does not modify C' do
            merge

            set[:current].should_not be_changed
          end
        end

        describe 'if O != C, C = P' do
          let(:o) { new_qrs(adapt_model(Response.new(:question => q, :answer => a))) }
          let(:c) { new_qrs(adapt_model(Response.new(:question => q, :answer => a2))) }
          let(:p) { new_qrs(adapt_hash(:response, { 'question_id' => q.api_id, 'answer_id' => a2.api_id })) }

          it 'does not modify C' do
            merge

            set[:current].should_not be_changed
          end
        end

        describe 'if O != C != P' do
          let(:o) { new_qrs(adapt_model(Response.new(:question => q, :answer => a))) }
          let(:c) { new_qrs(adapt_model(Response.new(:question => q, :answer => a2))) }
          let(:p) { new_qrs(adapt_hash(:response, { 'question_id' => q.api_id, 'answer_id' => a3.api_id })) }

          it 'signals a conflict' do
            merge

            conflicts.should == {
              'QuestionResponseSet' => { uuid => { :self => { 'original' => o, 'current' => c, 'proposed' => p } } }
            }
          end
        end
      end
    end

    describe '#save' do
      include Field::Adoption

      let(:contact) { Factory(:contact) }
      let(:event) { Factory(:event) }
      let(:response_set) { Factory(:response_set, :instrument => instrument, :participant => participant, :person => person) }
      let(:instrument) { Factory(:instrument) }
      let(:person) { Factory(:person) }
      let(:participant) { Factory(:participant) }
      let(:qrs) { QuestionResponseSet.new }

      let(:ac) { adapt_model(contact) }
      let(:ae) { adapt_model(event) }
      let(:rs) { adapt_model(response_set) }
      let(:ai) { adapt_model(instrument) }
      let(:pe) { adapt_model(person) }
      let(:pa) { adapt_model(participant) }

      before do
        subject.contacts = {
          'c1' => {
            :original => nil,
            :current => ac,
            :proposed => nil
          }
        }

        subject.events = {
          'e1' => {
            :original => nil,
            :current => ae,
            :proposed => nil
          }
        }

        subject.instruments = {
          'i1' => {
            :original => nil,
            :current => ai,
            :proposed => nil
          }
        }

        subject.response_sets = {
          'rs1' => {
            :original => nil,
            :current => rs,
            :proposed => nil
          }
        }

        subject.people = {
          'p1' => {
            :original => nil,
            :current => pe,
            :proposed => nil
          }
        }

        subject.participants = {
          'p1' => {
            :original => nil,
            :current => pa,
            :proposed => nil
          }
        }

        subject.question_response_sets = {
          'q1' => {
            :original => nil,
            :current => qrs,
            :proposed => nil
          }
        }
      end

      it 'skips nil entities' do
        subject.instruments = { 'p1' => {} }

        subject.save.should be_true
      end

      describe 'on success' do
        before do
          @ret = subject.save
        end

        it 'returns true' do
          @ret.should be_true
        end
      end

      describe 'on failure' do
        before do
          ae.stub!(:save => false)

          @ret = subject.save
        end

        it 'returns false' do
          @ret.should be_false
        end
      end
    end
  end
end
