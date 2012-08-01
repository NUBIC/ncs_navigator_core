require 'spec_helper'
require 'set'

require File.expand_path('../example_data', __FILE__)

module Psc
  describe ScheduledActivityReport do
    include_context 'example data'

    describe '.from_psc' do
      let(:psc) { mock }

      let(:filters) do
        {
          :start_date => '2012-02-01',
          :end_date => '2012-03-01',
          :state => PatientStudyCalendar::ACTIVITY_SCHEDULED
        }
      end

      before do
        psc.should_receive(:scheduled_activities_report).
          with(:start_date => '2012-02-01', :end_date => '2012-03-01', :state =>
               PatientStudyCalendar::ACTIVITY_SCHEDULED).and_return(data)

        @report = ScheduledActivityReport.from_psc(psc, filters)
      end

      it "sets the report's filters" do
        @report.filters.should == data['filters']
      end
    end

    describe '#process' do
      R = ScheduledActivityReport

      let(:report) { ::Psc::ScheduledActivityReport.from_json(data) }

      before do
        report.process
      end

      it 'finds people' do
        report.people.should == Set.new([R::Person.new(person_id)])
      end

      it 'finds contacts' do
        person = R::Person.new(person_id)

        report.contacts.should == Set.new([R::Contact.new(scheduled_date, person)])
      end

      it 'finds surveys' do
        report.surveys.should == Set.new([R::Survey.new(instrument_pregnotpreg)])
      end

      it 'finds events' do
        person = R::Person.new(person_id)
        contact = R::Contact.new(scheduled_date, person)

        report.events.should == Set.new([
          R::Event.new(event_informed_consent, ideal_date, contact, person),
          R::Event.new(event_data_collection, ideal_date, contact, person)
        ])
      end

      it 'finds instruments' do
        person = R::Person.new(person_id)
        contact = R::Contact.new(scheduled_date, person)
        event = R::Event.new(event_data_collection, ideal_date, contact, person)
        survey = R::Survey.new(instrument_pregnotpreg)

        report.instruments.should == Set.new([
          R::Instrument.new(survey, activity_name, event, person)
        ])
      end

      # NOTE: This isn't actually testing for ContactLinks.  It, like the rest
      # of the examples, is testing for ContactLink precursors.
      it 'links a person, contact, event, and instrument' do
        person = R::Person.new(person_id)
        contact = R::Contact.new(scheduled_date, person)
        event1 = R::Event.new(event_informed_consent, ideal_date, contact, person)
        event2 = R::Event.new(event_data_collection, ideal_date, contact, person)
        survey = R::Survey.new(instrument_pregnotpreg)
        instrument = R::Instrument.new(survey, activity_name, event2, person)

        report.contact_links.should == Set.new([
          R::ContactLink.new(person, contact, event1, nil),
          R::ContactLink.new(person, contact, event2, instrument)
        ])
      end
    end
  end
end
