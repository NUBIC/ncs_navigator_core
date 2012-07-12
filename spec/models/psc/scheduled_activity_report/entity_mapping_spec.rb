require 'spec_helper'

require 'set'

class Psc::ScheduledActivityReport
  describe EntityMapping do
    EM = EntityMapping

    let(:data) { JSON.parse(File.read(File.expand_path('../../ex1.json', __FILE__))) }
    let(:report) { ::Psc::ScheduledActivityReport.from_json(data) }

    # These values are derived from ex1.json.
    let(:activity_name) { 'Low-Intensity Interview' }
    let(:event_data_collection) { 'event:low_intensity_data_collection' }
    let(:event_informed_consent) { 'event:informed_consent' }
    let(:ideal_date) { '2012-07-06' }
    let(:instrument_pregnotpreg) { 'instrument:ins_que_lipregnotpreg_int_li_p2_v2.0' }
    let(:person_id) { '2f85c94e-edbb-4cbe-b9ab-5f12c033323f' }
    let(:scheduled_date) { '2012-07-10' }

    before do
      report.extend(EntityMapping)
    end

    describe '#process' do
      before do
        report.process
      end

      it 'finds people' do
        report.people.should == Set.new([EM::Person.new(person_id)])
      end

      it 'finds contacts' do
        person = EM::Person.new(person_id)

        report.contacts.should == Set.new([EM::Contact.new(scheduled_date, person)])
      end

      it 'finds events' do
        person = EM::Person.new(person_id)
        contact = EM::Contact.new(scheduled_date, person)

        report.events.should == Set.new([
          EM::Event.new(event_informed_consent, ideal_date, contact, person),
          EM::Event.new(event_data_collection, ideal_date, contact, person)
        ])
      end

      it 'finds instruments' do
        person = EM::Person.new(person_id)
        contact = EM::Contact.new(scheduled_date, person)
        event = EM::Event.new(event_data_collection, ideal_date, contact, person)
        
        report.instruments.should == Set.new([
          EM::Instrument.new(instrument_pregnotpreg, activity_name, event, person)
        ])
      end

      # NOTE: This isn't actually testing for ContactLinks.  It, like the rest
      # of the examples, is testing for ContactLink precursors.
      it 'links a person, contact, event, and instrument' do
        person = EM::Person.new(person_id)
        contact = EM::Contact.new(scheduled_date, person)
        event1 = EM::Event.new(event_informed_consent, ideal_date, contact, person)
        event2 = EM::Event.new(event_data_collection, ideal_date, contact, person)
        instrument = EM::Instrument.new(instrument_pregnotpreg, activity_name, event2, person)

        report.contact_links.should == Set.new([
          EM::ContactLink.new(person, contact, event1, nil),
          EM::ContactLink.new(person, contact, event2, instrument)
        ])
      end
    end
  end
end
