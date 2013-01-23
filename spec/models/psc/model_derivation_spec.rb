require 'set'
require 'spec_helper'

require File.expand_path('../../../shared/models/logger', __FILE__)
require File.expand_path('../report_without_child_instruments', __FILE__)
require File.expand_path('../report_with_child_instruments', __FILE__)
require File.expand_path('../../psc/activity_label_helpers', __FILE__)

module Psc
  describe ModelDerivation do
    include_context 'logger'

    IE = Psc::ImpliedEntities

    # ------------------------------------------------------------------------

    # Variables referenced in the shared example groups are defined in:
    #
    # 1. report_without_child_instruments.rb
    # 2. report_with_child_instruments.rb
    #
    # You're encouraged to have those open in another buffer while reading
    # this spec.
    shared_examples_for 'an event mapper' do
      it 'finds events' do
        person = IE::Person.new(person_id)
        contact = IE::Contact.new(scheduled_date, person)

        expected_events = event_labels.map do |el|
          IE::Event.new(el, ideal_date, contact, person)
        end

        report.events.should == Set.new(expected_events)
      end
    end

    shared_examples_for 'a person mapper' do
      it 'finds people' do
        report.people.should == Set.new([IE::Person.new(person_id)])
      end
    end

    shared_examples_for 'a contact mapper' do
      it 'finds contacts' do
        person = IE::Person.new(person_id)

        report.contacts.should == Set.new([IE::Contact.new(scheduled_date, person)])
      end
    end

    # ------------------------------------------------------------------------

    let(:report) { ScheduledActivityReport.new(logger) }

    before do
      report.populate_from_report(data)
      report.extend(ModelDerivation)
      report.derive_models
    end

    describe 'without child instruments' do
      include_context 'report without child instruments'

      it_should_behave_like 'a contact mapper'
      it_should_behave_like 'a person mapper'
      it_should_behave_like 'an event mapper'

      it 'finds instruments' do
        person = IE::Person.new(person_id)
        contact = IE::Contact.new(scheduled_date, person)
        event = IE::Event.new(event_data_collection, ideal_date, contact, person)
        survey = IE::Survey.new(instrument_pregnotpreg, nil, nil)

        report.instruments.should == Set.new([
          IE::Instrument.new(survey, nil, activity_name, event, person)
        ])
      end

      it 'links a person, contact, event, and instrument' do
        person = IE::Person.new(person_id)
        contact = IE::Contact.new(scheduled_date, person)
        event = IE::Event.new(event_data_collection, ideal_date, contact, person)
        survey = IE::Survey.new(instrument_pregnotpreg, nil, nil)
        instrument = IE::Instrument.new(survey, nil, activity_name, event, person)

        report.contact_links.should == Set.new([
          IE::ContactLink.new(person, contact, event, instrument)
        ])
      end

      it 'produces one plan per instrument' do
        person = IE::Person.new(person_id)
        contact = IE::Contact.new(scheduled_date, person)
        event = IE::Event.new(event_data_collection, ideal_date, contact, person)
        survey = IE::Survey.new(instrument_pregnotpreg, nil, nil)
        instrument = IE::Instrument.new(survey, nil, activity_name, event, person)

        expected_plan = InstrumentPlan.new(instrument, [survey])

        report.instrument_plans.should == Set.new([expected_plan])
      end
    end

    describe 'with child instruments' do
      include ActivityLabelHelpers

      include_context 'report with child instruments'

      it_should_behave_like 'a contact mapper'
      it_should_behave_like 'a person mapper'
      it_should_behave_like 'an event mapper'

      it 'finds root instruments' do
        person = IE::Person.new(person_id)
        contact = IE::Contact.new(scheduled_date, person)
        event = IE::Event.new(event_birth, ideal_date, contact, person)
        survey = IE::Survey.new(instrument_birth, al('participant_type:mother'), nil)

        report.instruments.should == Set.new([
          IE::Instrument.new(survey, nil, activity_name, event, person)
        ])
      end

      it 'produces one plan for each root instrument' do
        person = IE::Person.new(person_id)
        contact = IE::Contact.new(scheduled_date, person)
        event = IE::Event.new(event_birth, ideal_date, contact, person)
        root_survey = IE::Survey.new(instrument_birth, al('participant_type:mother'), nil)
        child_survey = IE::Survey.new(instrument_baby_name, al('participant_type:child'), al('order:01_01'))
        root_instrument = IE::Instrument.new(root_survey, nil, activity_name, event, person)

        expected_plan = InstrumentPlan.new(root_instrument, [root_survey, child_survey])

        report.instrument_plans.should == Set.new([expected_plan])
      end
    end
  end
end
