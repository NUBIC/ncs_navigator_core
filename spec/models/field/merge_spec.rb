# -*- coding: utf-8 -*-

require 'spec_helper'

require 'stringio'
require 'json'

require File.expand_path('../shared_merge_behaviors', __FILE__)

SCHEMA_FILE = "#{Rails.root}/vendor/ncs_navigator_schema/fieldwork_schema.json"
SCHEMA = JSON.parse(File.read(SCHEMA_FILE))

module Field
  describe Merge do
    subject do
      Class.new(Superposition) do
        include Merge
      end.new
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
      let(:properties) do
        SCHEMA['properties']['contacts']['items']['properties']['events']['items']['properties']
      end

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
      let(:properties) do
        SCHEMA['properties']['contacts']['items']['properties']['events']['items']['properties']['instruments']['items']['properties']
      end

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
    end

    describe '#grouped_responses' do
      include NcsNavigator::Core::Fieldwork::Adapters

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
        subject.responses = {
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
        subject.grouped_responses.should == {
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
  end
end
