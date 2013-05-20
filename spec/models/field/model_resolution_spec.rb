require 'spec_helper'
require 'set'

require File.expand_path('../example_data', __FILE__)
require File.expand_path('../../../shared/models/logger', __FILE__)

module Field
  describe ModelResolution do
    include_context 'example data'
    include_context 'logger'

    class TestReport < ScheduledActivityReport
      attr_accessor :staff_id

      include ModelResolution
    end

    let(:report) do
      TestReport.new(logger).tap do |r|
        r.populate_from_report(data)
      end
    end

    before do
      report.derive_models
    end

    describe '#reify_models' do
      let(:staff_id) { 'fa542082-c96f-4886-a6bc-cc9a546d787a' }

      before do
        report.staff_id = staff_id
      end

      describe 'with #staff_id blank' do
        before do
          report.staff_id = nil
        end

        it 'raises an error' do
          lambda { report.reify_models }.should raise_error
        end
      end

      describe 'for people' do
        it 'finds people in Cases' do
          p = Factory(:person, :person_id => person_id)

          report.reify_models

          report.resolutions.values.should include(p)
        end

        it 'logs an error if a person cannot be found' do
          report.reify_models

          log.should =~ /cannot map \{person ID = #{person_id}\} to a person/i
        end
      end

      describe 'for surveys' do
        it 'finds surveys in Cases' do
          s = Factory(:survey, :access_code => 'ins-que-lipregnotpreg-int-li-p2-v2-0')

          report.reify_models

          report.resolutions.values.should include(s)
        end

        it 'logs an error if a survey cannot be found' do
          report.reify_models

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

          report.reify_models

          report.resolutions.values.should include(e1)
          report.resolutions.values.should include(e2)
        end

        it 'logs an error if an event cannot be found' do
          report.reify_models

          log.should =~ /cannot map \{event label = low_intensity_data_collection, ideal date = #{ideal_date}, participant = #{pa.p_id}\} to an event/i
          log.should =~ /cannot map \{event label = informed_consent, ideal date = #{ideal_date}, participant = #{pa.p_id}\} to an event/i
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
            report.reify_models

            instrument = report.resolutions.values.detect { |v| ::Instrument === v }
            instrument.should_not be_nil
          end

          describe 'the started instrument' do
            let(:instrument) do
              report.resolutions.values.detect { |v| ::Instrument === v }
            end

            before do
              report.reify_models
            end

            it 'is a new record' do
              instrument.should be_new_record
            end

            it 'has a response set' do
              instrument.response_sets.first.should_not be_nil
            end

            it 'is linked to the event' do
              instrument.event.should == e
            end

            it 'is linked to the survey' do
              instrument.survey.should == s
            end
          end

          describe "the intermediate instruments" do
            let(:derived) { report.intermediate_instruments.keys[0] }
            let(:intermediate) { report.intermediate_instruments[derived][0] }

            before do
              report.reify_models
            end

            it "should generate one" do
              report.intermediate_instruments[derived].size.should == 1
            end

            it "should have respondent" do
              intermediate.respondent.should == p
            end

            it "should have a concerning participant" do
              intermediate.concerning.should == pa
            end

            it "should have a survey" do
              intermediate.survey.should == s
            end

            it "should not have a referenced survey" do
              intermediate.referenced_survey.should be_nil
            end

            it "should have an event" do
              intermediate.event.should == e
            end
          end
        end

        describe 'if the instrument has a person, THREE surveys, and event' do
          let(:data_fn) { File.expand_path('../../../../features/fixtures/fakeweb/scheduled_activities_2013-04-24.json', __FILE__) }
          let(:data) { JSON.parse(File.read(data_fn)) }

          let(:person_id) { 'registered_with_psc' }

          let!(:s_part_one) { Factory(:survey, :access_code => 'ins-que-birth-int-ehpbhipbs-m3-0-v3-0-part-one', :title => 'Birth Interview Part One') }
          let!(:s_child) { Factory(:survey, :access_code => 'ins-que-birth-int-ehpbhipbs-m3-0-v3-0-birth-visit-baby-name-3', :title => 'Birth Interview Baby Name') }
          let!(:s_part_two) { Factory(:survey, :access_code => 'ins-que-birth-int-ehpbhipbs-m3-0-v3-0-part-two', :title => 'Birth Interview Part Two') }

          let!(:p) { Factory(:person, :person_id => person_id) }
          let!(:pa) { Factory(:participant) }

          before do
            # Link up.
            p.participant = pa
            p.save!
          end

          # 18 => birth data collection
          let!(:et) { NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', 18) }
          let(:ideal_date) { '2013-04-24' }
          let!(:e) { Factory(:event, :participant => pa, :event_start_date => ideal_date, :event_type => et) }

          it 'starts an instrument' do
            report.reify_models

            instrument = report.resolutions.values.detect { |v| ::Instrument === v }
            instrument.should_not be_nil
          end

          describe "the intermediate instruments" do
            let(:derived) { report.intermediate_instruments.keys[0] }
            let(:first) { report.intermediate_instruments[derived][0] }
            let(:second) { report.intermediate_instruments[derived][1] }
            let(:third) { report.intermediate_instruments[derived][2] }

            before do
              report.reify_models
            end

            it "should generate three" do
              report.intermediate_instruments[derived].size.should == 3
            end

            describe "the mother survey" do
              it 'has a survey' do
                first.survey.should == s_part_one
              end

              it 'has a survey respondent' do
                first.respondent.should == p
              end

              it 'has a concerning person' do
                first.concerning.should == pa
              end
            end

            describe "the child survey" do
              context 'when no child exists' do
                it 'has a survey' do
                  second.survey.should == s_child
                end

                it 'has a survey respondent' do
                  second.respondent.should == p
                end

                it 'has a concerning person' do
                  second.concerning.should_not == pa
                  second.concerning.should be_child_participant
                end
              end

              context 'when child exists' do
                let!(:child) { pa.create_child_person_and_participant!(:first_name => 'child') }
                
                before do
                  report.reify_models
                end

                it 'has a survey' do
                  second.survey.should == s_child
                end

                it 'has a survey respondent' do
                  second.respondent.should == p
                end

                it 'has a concerning person' do
                  second.concerning.should == child
                end
              end

              context 'when multiple children exists' do
                let!(:child_1) { pa.create_child_person_and_participant!(:first_name => 'child 1') }
                let!(:child_2) { pa.create_child_person_and_participant!(:first_name => 'child 2') }
                
                let(:survey_person_associations_collection) { instrument_plan.survey_person_associations_collection }

                before do
                  report.reify_models
                end

                it 'has a survey' do
                  second.survey.should == s_child
                  third.survey.should == s_child
                end

                it 'has a survey respondent' do
                  second.respondent.should == p
                  third.respondent.should == p
                end

                it 'has a concerning person' do
                  second.concerning.should == child_1
                  third.concerning.should == child_2
                end
              end
            end
          end
        end
      end

      describe 'for contacts' do
        let!(:p) { Factory(:person, :person_id => person_id) }

        describe 'if there exists a open contact for the scheduled date, person, and staff ID' do
          let!(:c) { Factory(:contact, :contact_date => scheduled_date) }

          before do
            Factory(:contact_link, :contact => c, :person => p, :staff_id => staff_id)
          end

          it 'reuses that contact' do
            report.reify_models

            report.resolutions.values.should include(c)
          end
        end

        describe 'if there exists a closed contact for the scheduled date, person, and staff ID' do
          let!(:c) { Factory(:contact, :contact_date => scheduled_date, :contact_end_time => '12:00') }

          before do
            Factory(:contact_link, :contact => c, :person => p, :staff_id => staff_id)
          end

          it 'starts a new contact' do
            report.reify_models

            contact = report.resolutions.values.detect { |v| Contact === v }
            contact.should be_new_record
          end
        end

        describe 'if there does not exist a contact for the scheduled date, person, and staff ID' do
          it 'starts a new contact' do
            report.reify_models

            contact = report.resolutions.values.detect { |v| Contact === v }
            contact.should be_new_record
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
              report.reify_models

              report.resolutions.values.should include(cl)
            end
          end

          describe 'if a link does not exist' do
            it 'builds links' do
              report.reify_models

              cl = report.resolutions.values.detect { |v| ::ContactLink === v }
              cl.should_not be_nil
            end

            describe 'the built link' do
              let(:links) do
                report.resolutions.values.select { |v| ::ContactLink === v }
              end

              before do
                report.reify_models
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

          report.staff_id = staff_id
          report.reify_models
        end

        it 'saves generated models' do
          report.save_models

          report.resolutions.values.none?(&:new_record?).should be_true
        end

        it 'returns true on success' do
          report.save_models.should be_true
        end
      end
    end
  end
end
