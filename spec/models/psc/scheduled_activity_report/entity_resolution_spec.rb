require 'spec_helper'
require 'set'

require File.expand_path('../../example_data', __FILE__)

class Psc::ScheduledActivityReport
  describe EntityResolution do
    include_context 'example data'

    let(:report) { ::Psc::ScheduledActivityReport.from_json(data) }

    before do
      report.extend(EntityResolution)
    end

    describe '#process' do
      let(:sio) { StringIO.new }
      let(:log) { sio.string }
      let(:staff_id) { 'fa542082-c96f-4886-a6bc-cc9a546d787a' }

      before do
        report.logger = ::Logger.new(sio)
        report.staff_id = staff_id
      end

      describe 'with #staff_id blank' do
        before do
          report.staff_id = nil
        end

        it 'raises an error' do
          lambda { report.process }.should raise_error
        end
      end

      describe 'for people' do
        it 'finds people in Cases' do
          p = Factory(:person, :person_id => person_id)

          report.process

          report.people.models.should == Set.new([p])
        end

        it 'logs an error if a person cannot be found' do
          report.process

          log.should =~ /cannot map \{person ID = #{person_id}\} to a person/i
        end
      end

      describe 'for surveys' do
        it 'finds surveys in Cases' do
          s = Factory(:survey, :access_code => 'ins-que-lipregnotpreg-int-li-p2-v2-0')

          report.process

          report.surveys.models.should == Set.new([s])
        end

        it 'logs an error if a survey cannot be found' do
          report.process

          log.should =~ /cannot map \{access code = ins_que_lipregnotpreg_int_li_p2_v2\.0\} to a survey/i
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

          report.process

          report.events.models.should == Set.new([e1, e2])
        end

        it 'logs an error if an event cannot be found' do
          report.process

          log.should =~ /cannot map \{label = event:low_intensity_data_collection, ideal date = #{ideal_date}, participant = #{pa.p_id}\} to an event/i
          log.should =~ /cannot map \{label = event:informed_consent, ideal date = #{ideal_date}, participant = #{pa.p_id}\} to an event/i
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

          let!(:s) { Factory(:survey, :access_code => 'ins-que-lipregnotpreg-int-li-p2-v2-0', :title => instrument_pregnotpreg) }

          it 'starts an instrument' do
            report.process

            report.instruments.models.first.should_not be_nil
          end

          describe 'the started instrument' do
            let(:instrument) { report.instruments.models.first }

            before do
              report.process
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
            report.process

            report.contacts.models.should == Set.new([c])
          end
        end

        describe 'if there does not exist a contact for the scheduled date, person, and staff ID' do
          it 'starts a new contact' do
            report.process

            report.contacts.models.first.should_not be_nil
          end

          describe 'the started contact' do
            let(:contact) { report.contacts.models.first }

            before do
              report.process
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

          let!(:s) { Factory(:survey, :access_code => 'ins-que-lipregnotpreg-int-li-p2-v2-0', :title => instrument_pregnotpreg) }
          let!(:c) { Factory(:contact, :contact_date => scheduled_date) }
          let!(:i) { ::Instrument.start(p, pa, nil, s, e).tap(&:save!) }

          describe 'if a link already exists' do
            let!(:cl) do
              Factory(:contact_link, :staff_id => staff_id,
                      :person => p, :event => e, :contact => c, :instrument => i)
            end

            it 'reuses that link' do
              report.process

              report.contact_links.models.should include(cl)
            end
          end

          describe 'if a link does not exist' do
            it 'builds links' do
              report.process

              report.contact_links.models.none?(&:nil?).should be_true
            end

            describe 'the built link' do
              let(:links) { report.contact_links.models }

              before do
                report.process
              end

              it 'contains staff ID' do
                links.all?(&:staff_id).should be_true
              end

              it 'can connect a contact, event, and person' do
                ok = links.detect do |cl|
                  %w(contact event person).all? { |a| cl.send(a) }
                end

                ok.should be_true
              end

              it 'can connect a contact, event, instrument, and person' do
                ok = links.detect do |cl|
                  %w(contact event instrument person).all? { |a| cl.send(a) }
                end

                ok.should be_true
              end
            end
          end
        end
      end
    end

    describe '#save_models' do
      let(:sio) { StringIO.new }
      let(:log) { sio.string }
      let(:staff_id) { 'fa542082-c96f-4886-a6bc-cc9a546d787a' }

      describe 'on success' do
        # Create prerequisites.
        let!(:p) { Factory(:person, :person_id => person_id) }
        let!(:pa) { Factory(:participant) }

        # 10 => informed consent, 33 => low-intensity data collection.
        let!(:et1) { NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', 10) }
        let!(:et2) { NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', 33) }
        let!(:e1) { Factory(:event, :participant => pa, :event_start_date => ideal_date, :event_type => et1) }
        let!(:e2) { Factory(:event, :participant => pa, :event_start_date => ideal_date, :event_type => et2) }
        let!(:s) { Factory(:survey, :access_code => 'ins-que-lipregnotpreg-int-li-p2-v2-0', :title => instrument_pregnotpreg) }

        before do
          # Link up.
          p.participant = pa
          p.save!

          report.logger = ::Logger.new(sio)
          report.staff_id = staff_id
          report.process

          report.save_models
        end

        it 'saves generated contacts' do
          report.contacts.models.none?(&:new_record?).should be_true
        end

        it 'saves generated instruments' do
          report.instruments.models.none?(&:new_record?).should be_true
        end

        it 'saves generated contact links' do
          report.contact_links.models.none?(&:new_record?).should be_true
        end
      end
    end
  end
end
