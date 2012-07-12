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

      it 'finds surveys' do
        report.surveys.should == Set.new([
          EM::Survey.new(instrument_pregnotpreg)
        ])
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
        survey = EM::Survey.new(instrument_pregnotpreg)

        report.instruments.should == Set.new([
          EM::Instrument.new(survey, activity_name, event, person)
        ])
      end

      # NOTE: This isn't actually testing for ContactLinks.  It, like the rest
      # of the examples, is testing for ContactLink precursors.
      it 'links a person, contact, event, and instrument' do
        person = EM::Person.new(person_id)
        contact = EM::Contact.new(scheduled_date, person)
        event1 = EM::Event.new(event_informed_consent, ideal_date, contact, person)
        event2 = EM::Event.new(event_data_collection, ideal_date, contact, person)
        survey = EM::Survey.new(instrument_pregnotpreg)
        instrument = EM::Instrument.new(survey, activity_name, event2, person)

        report.contact_links.should == Set.new([
          EM::ContactLink.new(person, contact, event1, nil),
          EM::ContactLink.new(person, contact, event2, instrument)
        ])
      end
    end

    describe '#resolve_models' do
      let(:sio) { StringIO.new }
      let(:log) { sio.string }
      let(:staff_id) { 'fa542082-c96f-4886-a6bc-cc9a546d787a' }

      before do
        report.logger = ::Logger.new(sio)
        report.staff_id = staff_id

        report.process
      end

      describe 'with #staff_id blank' do
        before do
          report.staff_id = nil
        end

        it 'raises an error' do
          lambda { report.resolve_models }.should raise_error
        end
      end

      describe 'for people' do
        it 'finds people in Cases' do
          p = Factory(:person, :person_id => person_id)

          report.resolve_models

          report.people.models.should == Set.new([p])
        end

        it 'logs an error if a person cannot be found' do
          report.resolve_models

          log.should =~ /cannot map {person ID = #{person_id}} to a person/i
        end
      end

      describe 'for surveys' do
        it 'finds surveys in Cases' do
          s = Factory(:survey, :access_code => 'ins_que_lipregnotpreg_int_li_p2')

          report.resolve_models

          report.surveys.models.should == Set.new([s])
        end

        it 'logs an error if a survey cannot be found' do
          report.resolve_models

          log.should =~ /cannot map {access code = ins_que_lipregnotpreg_int_li_p2} to a survey/i
        end
      end

      describe 'for events' do
        let!(:p) { Factory(:person, :person_id => person_id) }
        let!(:pa) { Factory(:participant) }

        before do
          # Link up.
          p.participant = pa
          p.save!
        end

        it 'finds events in Cases' do
          # 33 => low-intensity data collection, 10 => informed consent.
          et1 = NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', 33)
          e1 = Factory(:event, :participant => pa, :event_start_date => ideal_date, :event_type => et1)
          et2 = NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', 10)
          e2 = Factory(:event, :participant => pa, :event_start_date => ideal_date, :event_type => et2)

          report.resolve_models

          report.events.models.should == Set.new([e1, e2])
        end

        it 'logs an error if an event cannot be found' do
          report.resolve_models

          log.should =~ /cannot map {label = event:low_intensity_data_collection, ideal date = #{ideal_date}, participant = #{pa.p_id}} to an event/i
          log.should =~ /cannot map {label = event:informed_consent, ideal date = #{ideal_date}, participant = #{pa.p_id}} to an event/i
        end
      end

      shared_context 'one existing event' do
        let!(:p) { Factory(:person, :person_id => person_id) }
        let!(:pa) { Factory(:participant) }

        # 33 => low-intensity data collection.
        let!(:et) { NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', 33) }
        let!(:e) { Factory(:event, :participant => pa, :event_start_date => ideal_date, :event_type => et) }

        before do
          # Link up.
          p.participant = pa
          p.save!
        end
      end

      describe 'for instruments' do
        describe 'if the instrument has a person, survey, and event' do
          include_context 'one existing event'

          let!(:s) { Factory(:survey, :access_code => 'ins_que_lipregnotpreg_int_li_p2', :title => instrument_pregnotpreg) }

          it 'builds an instrument' do
            report.resolve_models

            report.instruments.models.first.should_not be_nil
          end

          describe 'the built instrument' do
            let(:instrument) { report.instruments.models.first }

            before do
              report.resolve_models
            end

            it 'is a new record' do
              instrument.should be_new_record
            end

            it 'has a response set' do
              instrument.response_set.should_not be_nil
            end

            it 'is linked to the event' do
              instrument.event.should == e
            end

            it 'is linked to the survey' do
              instrument.survey.should == s
            end
          end
        end
      end

      describe 'for contacts' do
        let!(:p) { Factory(:person, :person_id => person_id) }

        describe 'if there exists a contact for the scheduled date, person, and staff ID' do
          let!(:c) { Factory(:contact, :contact_date => scheduled_date) }

          before do
            Factory(:contact_link, :contact => c, :person => p, :staff_id => staff_id)
          end

          it 'reuses that contact' do
            report.resolve_models

            report.contacts.models.should == Set.new([c])
          end
        end

        describe 'if there does not exist a contact for the scheduled date, person, and staff ID' do
          it 'starts a new contact' do
            report.resolve_models

            report.contacts.models.first.should_not be_nil
          end

          describe 'the started contact' do
            let(:contact) { report.contacts.models.first }

            before do
              report.resolve_models
            end

            it 'is a new record' do
              contact.should be_new_record
            end
          end
        end
      end

      describe 'for contact links' do
        describe 'for (staff ID, person, contact, event, instrument)' do
          include_context 'one existing event'

          let!(:i) { Factory(:instrument, :event => e) }
          let!(:c) { Factory(:contact, :contact_date => scheduled_date) }

          describe 'if a link already exists' do
            let!(:cl) do
              Factory(:contact_link, :staff_id => staff_id,
                      :person => p, :event => e, :contact => c)
            end

            it 'reuses that link' do
              report.resolve_models

              report.contact_links.models.should == Set.new([cl])
            end
          end

          describe 'if a link does not exist' do
            it 'builds a link'
          end
        end
      end
    end
  end
end
