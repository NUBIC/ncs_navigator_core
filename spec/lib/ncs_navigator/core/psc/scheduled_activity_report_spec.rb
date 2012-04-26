# -*- coding: utf-8 -*-

require 'spec_helper'

module NcsNavigator::Core::Psc
  describe ScheduledActivityReport do
    let(:psc_data) do
      {
        'filters' => {
          'end_date' => '2012-03-01',
          'start_date' => '2012-02-01',
          'states' => ['Scheduled']
        },
        'rows' => [
          {"activity_name"=>"Pregnancy Probability Group Follow-Up SAQ",
           "activity_status"=>"Scheduled",
           "activity_type"=>"Instrument",
           "grid_id"=>"cbcc8575-b1b9-4bd1-8a3c-51b885b903b6",
           "ideal_date"=>"2012-02-16",
           "labels"=>
            ["event:pregnancy_probability",
             "instrument:ins_que_ppgfollup_saq_ehpbhili_p2_v1.1"],
           "last_change_reason"=>"Participant requested",
           "responsible_user"=>"pfr957",
           "scheduled_date"=>"2012-02-29",
           "scheduled_study_segment"=>
            {"grid_id"=>"976f857d-10e6-40e1-9767-4f9eb8f239eb",
             "start_date"=>"2012-02-16",
             "start_day"=>1},
           "site"=>"GCSC",
           "study"=>"NCS Hi-Lo",
           "subject"=>
            {"grid_id"=>"cdabfc40-578f-4dd5-8152-c5c501fcdf10",
             "name"=>"Betty Boop",
             "person_id"=>"b9696270-3586-012f-ca18-58b035fb69ca"}}
        ]
      }
    end

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
               PatientStudyCalendar::ACTIVITY_SCHEDULED).and_return(psc_data)

        @report = ScheduledActivityReport.from_psc(psc, filters)
      end

      it 'returns a ScheduledActivityReport' do
        @report.should be_an_instance_of(ScheduledActivityReport)
      end

      it "sets the report's filters" do
        @report.filters.should == psc_data['filters']
      end

      it "sets the report's rows" do
        @report.rows.should == psc_data['rows'].map { |r| ScheduledActivityReport::Row.new(r) }
      end
    end

    context 'entity mapping' do
      let(:participant) { Factory(:participant) }
      let(:person) { Factory(:person, :person_id => 'b9696270-3586-012f-ca18-58b035fb69ca') }
      let(:report) { ScheduledActivityReport.new }

      let(:logdev) { StringIO.new }
      let(:log) { logdev.string }

      before do
        Factory(:participant_person_link,
                :person => person,
                :participant => participant,
                :relationship_code => 1)

        report.rows = psc_data['rows'].map { |r| ScheduledActivityReport::Row.new(r) }
        report.logger = ::Logger.new(logdev)
      end

      describe '#map_persons' do
        let(:rows) do
          report.map_persons
          report.rows
        end

        it 'maps subject/person_id to Participant' do
          rows[0].participant.should == participant
        end

        it 'stores the Person representing the Participant' do
          rows[0].person.should == person
        end

        it 'maps unknown person IDs to nil' do
          person.update_attribute(:person_id, 'foo')

          rows[0].participant.should be_nil
        end

        it 'logs results' do
          report.map_persons

          log.should =~ /person search: 1 attempted, 1 matched/i
        end

        it 'logs failures' do
          original_person_id = person.person_id

          person.update_attribute(:person_id, 'foo')

          report.map_persons

          log.should =~ /person search: 1 attempted, 0 matched/i
          log.should =~ /could not match subject ID #{original_person_id} to a person/i
        end
      end

      describe '#map_events' do
        # pregnancy probability
        let(:event_type) { NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', 7) }
        let!(:event) { Factory(:event, :participant => participant, :event_start_date => Date.new(2012, 2, 16), :event_type => event_type) }

        it 'maps the first event label to an event on the participant' do
          report.map_persons
          report.map_events

          report.rows[0].event.should == event
        end

        it 'maps unknown labels to nil' do
          event.destroy

          report.map_persons
          report.map_events

          report.rows[0].event.should be_nil
        end

        it 'logs results' do
          report.map_persons
          report.map_events

          log.should =~ /event search: 1 attempted, 1 matched/i
        end

        it 'logs failures' do
          event.destroy

          event_label = 'event:pregnancy_probability'

          report.map_persons
          report.map_events

          log.should =~ /event search: 1 attempted, 0 matched/i
          log.should =~ /could not match event label #{event_label} to an event on subject id #{person.person_id}/i
        end
      end

      describe '#map_instruments' do
        let!(:event_type) { NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', 7) }
        let!(:event) { Factory(:event, :participant => participant, :event_start_date => Date.new(2012, 2, 16), :event_type => event_type) }
        let!(:survey) { Factory(:survey, :title => 'ins_que_ppgfollup_saq_ehpbhili_p2_v1.1', :access_code => 'ins_que_ppgfollup_saq_ehpbhili_p2') }
        let!(:response_set) { Factory(:response_set, :instrument => instrument, :survey => survey, :person => person) }
        let!(:instrument) { Factory(:instrument, :survey => survey) }

        let(:rows) do
          report.map_persons
          report.map_events
          report.map_instruments

          report.rows
        end

        it 'maps the first instrument label to an instrument' do
          rows[0].instrument.should == instrument
        end

        it 'builds an instrument if an appropriate one cannot be found' do
          response_set.destroy

          rows[0].instrument.should be_new_record
        end

        describe "if the row's event is nil" do
          before do
            event.destroy
          end

          it "sets the row's instrument to nil" do
            rows[0].instrument.should be_nil
          end
        end

        describe "if the row's person is nil" do
          before do
            ParticipantPersonLink.all.each(&:destroy)
            response_set.destroy
            person.destroy
          end

          it "sets the row's instrument to nil" do
            rows[0].instrument.should be_nil
          end
        end

        describe "if the row's survey is nil" do
          before do
            instrument.update_attribute(:survey, nil)
            response_set.destroy
            survey.destroy
          end

          it "sets the row's instrument to nil" do
            rows[0].instrument.should be_nil
          end
        end

        it 'logs results' do
          report.map_persons
          report.map_events
          report.map_instruments

          log.should =~ /instrument search: 1 attempted, 1 matched/i
        end

        it 'logs instantiations' do
          response_set.destroy
          instrument.destroy

          row = rows.first

          l = row.instrument_label
          subject_id = row.person_id

          log.should =~ /using newly instantiated instrument for instrument label #{l}, subject ID #{subject_id}/i
        end

        it 'logs failures' do
          event.destroy

          row = rows.first

          event_label = row.event_label
          l = row.instrument_label
          sac = row.survey_access_code
          subject_id = row.person_id

          log.should =~ /instrument search: 1 attempted, 0 matched/i
          log.should =~ /could not match instrument label #{l} to an instrument for subject ID #{subject_id}, survey access code #{sac}, event label #{event_label}/i
        end
      end

      describe '#map_contacts' do
        let!(:event_type) { NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', 7) }
        let!(:event) { Factory(:event, :participant => participant, :event_start_date => Date.new(2012, 2, 16), :event_type => event_type) }

        def do_mapping
          report.map_persons
          report.map_events
          report.map_contacts
        end

        let(:rows) do
          do_mapping

          report.rows
        end

        describe "if there is a non-closed contact with date equal to the row's scheduled date" do
          let!(:contact) do
            Factory(:contact, :contact_date => Date.new(2012, 2, 29))
          end

          before do
            Factory(:contact_link, :event => event, :contact => contact)
          end

          it 'maps that contact' do
            rows[0].contact.should == contact
          end
        end

        shared_examples_for 'a contact builder' do
          let(:row) { rows[0] }
          let(:row_contact) { row.contact }

          it 'builds a contact' do
            row_contact.should be_new_record
          end

          it "sets the contact's date to the row's scheduled date" do
            row_contact.contact_date.should == row.scheduled_date
          end

          it "adds the contact to the row's event" do
            row.event.contact_links.map(&:contact).should include(contact)
          end

          it 'does not set a contact end time' do
            row_contact.contact_end_time.should be_blank
          end

          it 'logs instantiations' do
            do_mapping

            el = row.event_label
            subject_id = row.person_id

            log.should =~ /using newly instantiated contact for event label #{el}, subject ID #{subject_id}/i
          end
        end

        describe "if there is not a contact with date equal to the row's scheduled date" do let!(:contact) do
            Factory(:contact, :contact_date => Date.new(2011, 1, 1))
          end

          before do
            Factory(:contact_link, :event => event, :contact => contact)
          end

          it_should_behave_like 'a contact builder'
        end

        describe "if there is not a non-closed contact with date equal to the row's scheduled date" do
          let!(:contact) do
            Factory(:contact, :contact_date => Date.new(2012, 2, 29), :contact_end_time => '17:55')
          end

          before do
            Factory(:contact_link, :event => event, :contact => contact)

            report.map_persons
            report.map_events
            report.map_contacts
          end

          it_should_behave_like 'a contact builder'
        end

        describe 'if two rows share the same event and scheduled date' do
          before do
            report.rows = [
              OpenStruct.new(:event => event, :scheduled_date => '2011-02-28'),
              OpenStruct.new(:event => event, :scheduled_date => '2011-02-28')
            ]
          end

          describe 'and there is no suitable existing contact' do
            it 'shares the instantiated contact' do
              report.map_contacts

              report.rows.map { |r| r.contact.object_id }.uniq.length.should == 1
            end
          end
        end

        describe "if the row's event is nil" do
          before do
            event.destroy
          end

          it "sets the row's contact to nil" do
            rows[0].contact.should be_nil
          end
        end
      end

      describe '#save_entities' do
        let(:c) { Factory.build(:contact) }
        let(:e) { Factory(:event) }
        let(:i) { Instrument.start(p, s, e) }
        let(:p) { Factory(:person) }
        let(:s) { Factory(:survey, :title => 'ins_que_ppgfollup_saq_ehpbhili_p2_v1.1', :access_code => 'ins_que_ppgfollup_saq_ehpbhili_p2') }

        let(:r1) do
          OpenStruct.new(:contact => c,
                         :event => e,
                         :instrument => i,
                         :person => p,
                         :survey => s)
        end

        let(:staff_id) { 'test' }

        before do
          # Expected by Person#start_instrument.
          InstrumentEventMap.stub!(
            :instrument_type => NcsCode.for_attribute_name_and_local_code(:instrument_type, 4))

          report.rows = [r1]
        end

        it 'saves new contacts' do
          report.save_entities(staff_id)

          c.should_not be_new_record
        end

        it 'builds a contact link between a contact and its event' do
          report.save_entities(staff_id)

          ContactLink.exists?(:contact_id => c.id, :event_id => e.id).should be_true
        end

        it 'saves new instruments' do
          report.save_entities(staff_id)

          i.should_not be_new_record
        end

        it 'builds a contact link between an instrument and its event' do
          report.save_entities(staff_id)

          ContactLink.exists?(:event_id => e.id, :instrument_id => i.id).should be_true
        end

        it 'returns true if all entities were saved' do
          report.save_entities(staff_id).should be_true
        end

        it 'returns false if an instrument could not be saved' do
          i.stub!(:save => false)

          report.save_entities(staff_id).should be_false
        end

        it 'returns false if a contact could not be saved' do
          c.stub!(:save => false)

          report.save_entities(staff_id).should be_false
        end

        it 'returns false if links could not be established' do
          cl = stub.as_null_object
          ContactLink.stub!(:new => cl)
          cl.stub!(:save => false)

          report.save_entities(staff_id).should be_false
        end

        describe 'if a row does not have a contact' do
          before do
            r1.contact = nil
          end

          it 'does not raise NoMethodError' do
            lambda { report.save_entities(staff_id) }.should_not raise_error(NoMethodError)
          end
        end

        describe 'if a row does not have an instrument' do
          before do
            r1.instrument = nil
          end

          it 'does not raise NoMethodError' do
            lambda { report.save_entities(staff_id) }.should_not raise_error(NoMethodError)
          end
        end
      end
    end
  end
end