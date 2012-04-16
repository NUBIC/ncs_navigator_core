require 'spec_helper'

require 'stringio'
require 'json'

require File.expand_path('../shared_merge_behaviors', __FILE__)

SCHEMA_FILE = File.expand_path('../../../../../../vendor/ncs_navigator_schema/fieldwork_schema.json', __FILE__)
SCHEMA = JSON.parse(File.read(SCHEMA_FILE))

module NcsNavigator::Core::Fieldwork
  describe Merge do
    subject do
      Class.new do
        include Merge

        attr_accessor :conflicts
        attr_accessor :contacts
        attr_accessor :events
        attr_accessor :instruments

        def initialize
          self.conflicts = {}
          self.contacts = {}
          self.events = {}
          self.instruments = {}
        end
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
      it_merges 'incentive'
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
      it_merges 'start_date'
      it_merges 'start_time'
      it_merges 'status'
      it_merges 'supervisor_review'
      it_merges 'type'
      it_merges 'type_other'
    end
  end
end
