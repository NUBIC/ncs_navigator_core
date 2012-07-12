require 'spec_helper'

require 'set'

class Psc::ScheduledActivityReport
  describe EntityMapping do
    EM = EntityMapping

    let(:data) { JSON.parse(File.read(File.expand_path('../../ex1.json', __FILE__))) }
    let(:report) { ::Psc::ScheduledActivityReport.from_json(data) }

    before do
      report.extend(EntityMapping)
    end

    describe '#process' do
      before do
        report.process
      end

      it 'finds people' do
        report.people.should == Set.new([
          EM::Person.new('2f85c94e-edbb-4cbe-b9ab-5f12c033323f')
        ])
      end

      it 'finds contacts' do
        person = EM::Person.new('2f85c94e-edbb-4cbe-b9ab-5f12c033323f')

        report.contacts.should == Set.new([
          EM::Contact.new('2012-07-10', person)
        ])
      end

      it 'finds events' do
        person = EM::Person.new('2f85c94e-edbb-4cbe-b9ab-5f12c033323f')
        contact = EM::Contact.new('2012-07-10', person)

        report.events.should == Set.new([
          EM::Event.new('event:informed_consent', '2012-07-06', contact, person),
          EM::Event.new('event:low_intensity_data_collection', '2012-07-06', contact, person)
        ])
      end

      it 'finds instruments' do
        person = EM::Person.new('2f85c94e-edbb-4cbe-b9ab-5f12c033323f')
        contact = EM::Contact.new('2012-07-10', person)
        event = EM::Event.new('event:low_intensity_data_collection', '2012-07-06', contact, person)
        
        report.instruments.should == Set.new([
          EM::Instrument.new('instrument:ins_que_lipregnotpreg_int_li_p2_v2.0',
                             'Low-Intensity Interview',
                             event,
                             person)
        ])
      end

      # NOTE: This isn't testing for ContactLinks.  It, like the rest of the
      # examples, is testing for ContactLink precursors.
      it 'links a person, contact, event, and instrument' do
        person = EM::Person.new('2f85c94e-edbb-4cbe-b9ab-5f12c033323f')
        contact = EM::Contact.new('2012-07-10', person)
        event1 = EM::Event.new('event:informed_consent', '2012-07-06', contact, person)
        event2 = EM::Event.new('event:low_intensity_data_collection', '2012-07-06', contact, person)
        instrument = EM::Instrument.new('instrument:ins_que_lipregnotpreg_int_li_p2_v2.0',
                                        'Low-Intensity Interview',
                                        event2,
                                        person)
        
        report.contact_links.should == Set.new([
          EM::ContactLink.new(person, contact, event1, nil),
          EM::ContactLink.new(person, contact, event2, instrument)
        ])
      end
    end
  end
end
