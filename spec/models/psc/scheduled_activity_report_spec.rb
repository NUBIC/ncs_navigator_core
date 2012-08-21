require 'spec_helper'
require 'set'

require File.expand_path('../report_without_child_instruments', __FILE__)
require File.expand_path('../report_with_child_instruments', __FILE__)

module Psc
  R = ScheduledActivityReport

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
      person = R::Person.new(person_id)
      contact = R::Contact.new(scheduled_date, person)

      events = event_labels.map { |el| R::Event.new(el, ideal_date, contact, person) }

      report.events.should == Set.new(events)
    end
  end

  shared_examples_for 'a person mapper' do
    it 'finds people' do
      report.people.should == Set.new([R::Person.new(person_id)])
    end
  end

  shared_examples_for 'a contact mapper' do
    it 'finds contacts' do
      person = R::Person.new(person_id)

      report.contacts.should == Set.new([R::Contact.new(scheduled_date, person)])
    end
  end

  shared_examples_for 'a survey mapper' do
    it 'finds surveys' do
      surveys = survey_labels.map { |sl| R::Survey.new(sl) }

      report.surveys.should == Set.new(surveys)
    end
  end

  describe ScheduledActivityReport do
    describe 'without child instruments' do
      let(:report) { ::Psc::ScheduledActivityReport.from_json(data) }

      include_context 'report without child instruments'

      before do
        report.process
      end

      it_should_behave_like 'a PSC report wrapper'
      it_should_behave_like 'a contact mapper'
      it_should_behave_like 'a person mapper'
      it_should_behave_like 'a survey mapper'
      it_should_behave_like 'an event mapper'

      it 'finds instruments' do
        person = R::Person.new(person_id)
        contact = R::Contact.new(scheduled_date, person)
        event = R::Event.new(event_data_collection, ideal_date, contact, person)
        survey = R::Survey.new(instrument_pregnotpreg)

        report.instruments.should == Set.new([
          R::Instrument.new(survey, nil, activity_name, event, person)
        ])
      end

      it 'links a person, contact, event, and instrument' do
        person = R::Person.new(person_id)
        contact = R::Contact.new(scheduled_date, person)
        event = R::Event.new(event_data_collection, ideal_date, contact, person)
        survey = R::Survey.new(instrument_pregnotpreg)
        instrument = R::Instrument.new(survey, nil, activity_name, event, person)

        report.contact_links.should == Set.new([
          R::ContactLink.new(person, contact, event, instrument)
        ])
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
      it_should_behave_like 'a survey mapper'
      it_should_behave_like 'an event mapper'

      it 'finds instruments' do
        person = R::Person.new(person_id)
        contact = R::Contact.new(scheduled_date, person)
        event = R::Event.new(event_birth, ideal_date, contact, person)
        referenced_survey = R::Survey.new(instrument_birth)
        survey = R::Survey.new(instrument_baby_name)

        report.instruments.should == Set.new([
          R::Instrument.new(survey, referenced_survey, activity_name, event, person)
        ])
      end
    end
  end
end
