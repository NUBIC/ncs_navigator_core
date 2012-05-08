# -*- coding: utf-8 -*-

require 'spec_helper'

require 'stringio'
require 'json'

require File.expand_path('../shared_merge_behaviors', __FILE__)

SCHEMA_FILE = File.expand_path('../../../../../../vendor/ncs_navigator_schema/fieldwork_schema.json', __FILE__)
SCHEMA = JSON.parse(File.read(SCHEMA_FILE))

module NcsNavigator::Core::Fieldwork
  describe Merge do
    subject do
      Class.new(Superposition) do
        include Merge
      end.new
    end

    describe '#conflicted?' do
      describe 'if the conflict report is empty' do
        before do
          subject.conflicts = {}
        end

        it 'returns false' do
          subject.should_not be_conflicted
        end
      end

      describe 'if the conflict report is not empty' do
        before do
          subject.conflicts = {
            'Contact' => {
              'foo' => {
                :original => {},
                :current => {},
                :proposed => {}
              }
            }
          }
        end

        it 'returns true' do
          subject.should be_conflicted
        end
      end
    end

    def self.it_merges(property)
      describe "##{property}" do
        it_behaves_like 'an attribute merge', entity, property do
          let(:vessel) { subject }
        end
      end
    end

    def self.when_merging(entity, &block)
      describe "on #{entity}" do
        cattr_accessor :entity

        self.entity = entity

        it_behaves_like 'an entity merge', entity do
          let(:vessel) { subject }
        end

        instance_eval(&block)
      end
    end

    when_merging 'Contact' do
      let(:properties) do
        SCHEMA['properties']['contacts']['items']['properties']
      end

      it_merges 'contact_date'
      it_merges 'disposition'
      it_merges 'distance_traveled'
      it_merges 'end_time'
      it_merges 'interpreter'
      it_merges 'interpreter_other'
      it_merges 'language'
      it_merges 'language_other'
      it_merges 'location'
      it_merges 'location_other'
      it_merges 'private'
      it_merges 'private_detail'
      it_merges 'start_time'
      it_merges 'type'
      it_merges 'who_contacted'
      it_merges 'who_contacted_other'
    end

    when_merging 'Event' do
      let(:properties) do
        SCHEMA['properties']['contacts']['items']['properties']['events']['items']['properties']
      end

      it_merges 'break_off'
      it_merges 'comments'
      it_merges 'disposition'
      it_merges 'disposition_category'
      it_merges 'end_date'
      it_merges 'end_time'
      it_merges 'incentive_type'
      it_merges 'incentive_cash'
      it_merges 'repeat_key'
      it_merges 'start_date'
      it_merges 'start_time'
      it_merges 'type'
      it_merges 'type_other'
    end

    when_merging 'Instrument' do
      let(:properties) do
        SCHEMA['properties']['contacts']['items']['properties']['events']['items']['properties']['instruments']['items']['properties']
      end

      it_merges 'breakoff'
      it_merges 'comments'
      it_merges 'data_problem'
      it_merges 'end_date'
      it_merges 'end_time'
      it_merges 'method_administered'
      it_merges 'mode_administered'
      it_merges 'mode_administered_other'
      it_merges 'repeat_key'
      it_merges 'start_date'
      it_merges 'start_time'
      it_merges 'status'
      it_merges 'supervisor_review'
      it_merges 'type'
      it_merges 'type_other'
    end

    describe 'on ResponseGroups O, C, P' do
      let(:conflicts) { subject.conflicts }
      let(:entity) { 'ResponseGroup' }
      let(:question_id) { 'foo' }
      let(:rg1) { ResponseGroup.new }
      let(:rg2) { ResponseGroup.new }

      before do
        subject.response_groups = {
          question_id => {
            :original => o,
            :current => c,
            :proposed => p
          }
        }
      end

      def set
        subject.response_groups[question_id]
      end

      def merge
        subject.merge
      end

      describe 'if O = C = P = nil' do
        let(:o) { nil }
        let(:c) { nil }
        let(:p) { nil }

        it 'leaves C at nil' do
          merge

          set[:current].should be_nil
        end
      end

      describe 'if O = P = nil and C exists' do
        let(:o) { nil }
        let(:c) { rg1 }
        let(:p) { nil }

        it 'does not modify C' do
          merge

          set[:current].should_not be_changed
        end
      end

      describe 'if C = P = nil and O exists' do
        let(:o) { rg1 }
        let(:c) { nil }
        let(:p) { nil }

        it 'leaves C at nil' do
          merge

          set[:current].should be_nil
        end
      end

      describe 'if O exists, C is nil, and P is new' do
        let(:o) { rg1 }
        let(:c) { nil }
        let(:p) { rg2 }

        it 'signals a conflict' do
          merge

          conflicts.should == {
            entity => { question_id => { :self => { :original => o, :current => c, :proposed => p } } }
          }
        end
      end

      describe 'if O exists, C exists, and P is nil' do
        let(:o) { rg1 }
        let(:c) { rg2 }
        let(:p) { nil }

        it 'does not modify C' do
          merge

          set[:current].should_not be_changed
        end
      end

      describe 'if O = C = nil and P is new' do
        include Adapters

        let(:o) { nil }
        let(:c) { nil }
        let(:p) { rg1 }

        before do
          rg1 << adapt_hash(:response, { :question_id => question_id, :answer_id => 'bar' })
        end

        it "creates Responses from P" do
          merge

          set[:current].should be_new_record
          set[:current].responses.length.should == 1
        end
      end

      describe 'if C exists and P is new' do
        include Adapters

        let(:o) { nil }
        let(:c) { rg1 }
        let(:p) { rg2 }

        let!(:a) { Factory(:answer, :api_id => 'bar', :response_class => 'string') }
        let!(:q) { Factory(:question, :api_id => question_id) }

        let(:r) do
          Response.new.tap do |r|
            r.question = q
            r.api_id = 'foo'
          end
        end

        let(:rc) { adapt_model(r) }
        let(:rp) { adapt_hash(:response, { 'uuid' => 'foo', 'question_id' => question_id, 'answer_id' => 'bar' }) }

        describe 'if C =~ P' do
          before do
            c << rc
            p << rp

            c.should =~ p
          end

          describe 'for each response Rp, Rc' do
            it 'copies Rp#answer_id to Rc#answer_id' do
              merge

              set[:current].responses.values.first.answer_id.should == a.api_id
            end

            it 'copies Rp#value to Rc#value' do
              rp.value = 'foo'

              merge

              set[:current].responses.values.first.value.should == 'foo'
            end
          end
        end

        describe 'if !(C =~ P)' do
          before do
            c << stub(:uuid => 'foo', :question_id => question_id)
            p << stub(:uuid => 'foo', :question_id => question_id)
            p << stub(:uuid => 'bar', :question_id => question_id)
          end

          it 'signals a conflict' do
            merge

            conflicts.should == {
              entity => { question_id => { :self => { :original => o, :current => c, :proposed => p } } }
            }
          end
        end
      end
    end
  end
end
