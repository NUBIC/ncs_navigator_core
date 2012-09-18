require 'spec_helper'
require 'set'

require File.expand_path('../report_without_child_instruments', __FILE__)
require File.expand_path('../report_with_child_instruments', __FILE__)

module Psc
  shared_examples_for 'a PSC report wrapper' do
    describe '.from_psc' do
      let(:psc) { mock }

      let(:filters) do
        {
          :start_date => '2012-02-01',
          :end_date => '2012-03-01',
          :state => Psc::ScheduledActivity::SCHEDULED
        }
      end

      before do
        psc.should_receive(:scheduled_activities_report).
          with(:start_date => '2012-02-01', :end_date => '2012-03-01', :state =>
               Psc::ScheduledActivity::SCHEDULED).and_return(data)

        @report = ScheduledActivityReport.from_psc(psc, filters)
      end

      it "sets the report's filters" do
        @report.filters.should == data['filters']
      end
    end
  end

  shared_examples_for 'an event mapper' do
    it 'finds events' do
      person = I::Person.new(person_id)
      contact = I::Contact.new(scheduled_date, person)

      events = event_labels.map { |el| I::Event.new(el, ideal_date, contact, person) }

      report.events.should == Set.new(events)
    end
  end

  shared_examples_for 'a person mapper' do
    it 'finds people' do
      report.people.should == Set.new([I::Person.new(person_id)])
    end
  end

  shared_examples_for 'a contact mapper' do
    it 'finds contacts' do
      person = I::Person.new(person_id)

      report.contacts.should == Set.new([I::Contact.new(scheduled_date, person)])
    end
  end

  describe ScheduledActivityReport do
    I = ScheduledActivity::Implications

    describe 'without child instruments' do
      let(:report) { ::Psc::ScheduledActivityReport.from_json(data) }

      include_context 'report without child instruments'

      before do
        report.process
      end

      it_should_behave_like 'a PSC report wrapper'
      it_should_behave_like 'a contact mapper'
      it_should_behave_like 'a person mapper'
      it_should_behave_like 'an event mapper'

      it 'finds instruments' do
        person = I::Person.new(person_id)
        contact = I::Contact.new(scheduled_date, person)
        event = I::Event.new(event_data_collection, ideal_date, contact, person)
        survey = I::Survey.new(instrument_pregnotpreg, nil, nil)

        report.instruments.should == Set.new([
          I::Instrument.new(survey, nil, activity_name, event, person)
        ])
      end

      it 'links a person, contact, event, and instrument' do
        person = I::Person.new(person_id)
        contact = I::Contact.new(scheduled_date, person)
        event = I::Event.new(event_data_collection, ideal_date, contact, person)
        survey = I::Survey.new(instrument_pregnotpreg, nil, nil)
        instrument = I::Instrument.new(survey, nil, activity_name, event, person)

        report.contact_links.should == Set.new([
          I::ContactLink.new(person, contact, event, instrument)
        ])
      end

      it 'produces one plan per instrument' do
        person = I::Person.new(person_id)
        contact = I::Contact.new(scheduled_date, person)
        event = I::Event.new(event_data_collection, ideal_date, contact, person)
        survey = I::Survey.new(instrument_pregnotpreg, nil, nil)
        instrument = I::Instrument.new(survey, nil, activity_name, event, person)

        expected_plan = Psc::InstrumentPlan.new(instrument, [survey])

        report.instrument_plans.should == Set.new([expected_plan])
      end
    end

    describe 'with child instruments' do
      let(:report) { ::Psc::ScheduledActivityReport.from_json(data) }

      include_context 'report with child instruments'

      before do
        report.process
      end

      it_should_behave_like 'a PSC report wrapper'
      it_should_behave_like 'a contact mapper'
      it_should_behave_like 'a person mapper'
      it_should_behave_like 'an event mapper'

      it 'finds root instruments' do
        person = I::Person.new(person_id)
        contact = I::Contact.new(scheduled_date, person)
        event = I::Event.new(event_birth, ideal_date, contact, person)
        survey = I::Survey.new(instrument_birth, 'mother', nil)

        report.instruments.should == Set.new([
          I::Instrument.new(survey, nil, activity_name, event, person)
        ])
      end

      it 'produces one plan for each root instrument' do
        person = I::Person.new(person_id)
        contact = I::Contact.new(scheduled_date, person)
        event = I::Event.new(event_birth, ideal_date, contact, person)
        root_survey = I::Survey.new(instrument_birth, 'mother', nil)
        child_survey = I::Survey.new(instrument_baby_name, 'child', '01_01')
        root_instrument = I::Instrument.new(root_survey, nil, activity_name, event, person)

        expected_plan = Psc::InstrumentPlan.new(root_instrument, [root_survey, child_survey])

        report.instrument_plans.should == Set.new([expected_plan])
      end
    end
  end
end
