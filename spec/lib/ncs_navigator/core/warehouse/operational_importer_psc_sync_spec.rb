# -*- coding: utf-8 -*-

require 'spec_helper'
require Rails.root + 'spec/warehouse_setup'

require 'ncs_navigator/core/warehouse'

module NcsNavigator::Core::Warehouse
  describe OperationalImporterPscSync, :warehouse, :redis do
    include NcsNavigator::Core::Spec::WarehouseSetup

    SEGMENT_IDS = {
      :pv1 => 'ca65bbbb-7e47-4f71-a4f0-071e7f73f380',
      :pv2 => 'cef89a1e-5a08-4d94-811d-1aea62700d61',
      :hi_child => '072db970-d32a-4006-83b0-3f0240833894',
      :lo_birth => '53318f20-d21f-452e-a8e8-3f2ed6bb6c93',
      :lo_ppg_12 => '76025607-f7aa-41e1-8ce9-29e0793cd6d4',
      :lo_postnatal => 'd0faf572-4208-4a43-adc6-5748f80ac321',
      :lo_hi_conversion => '34d4638b-6f7f-4801-881d-db242d6f7ee5',
      :pbs_provider_screening => 'f1ec472e-145b-48b4-b4f6-ec5d18e60dc5',
      :pbs_hospital_screening => 'fb403fbc-0ab3-4155-be82-a72d2386e77d'
    }

    let(:redis) { Rails.application.redis }
    let(:ns) { 'NcsNavigator::Core::Warehouse::OperationalImporter' }
    let(:responsible_user) { 'foobar' }

    let(:psc) { double(PatientStudyCalendar) }
    let(:psc_participant) { double(PscParticipant) }

    let(:importer) { OperationalImporterPscSync.new(psc, wh_config) }
    let(:template_xml) {
      Nokogiri::XML(File.read(File.expand_path(
            '../../../../../fixtures/psc/current_hilo_template_snapshot.xml', __FILE__)))
    }

    let(:p_id) { 'par-foo' }
    let(:person_id) { 'per-foo' }

    let(:participant) { Factory(:participant, :p_id => p_id) }
    let(:person) { Factory(:person, :person_id => person_id) }

    before do
      keys = redis.keys('*')
      redis.del(*keys) unless keys.empty?

      psc.stub!(:psc_participant).and_return(psc_participant)
      psc.stub!(:template_snapshot).and_return(template_xml)
      psc_participant.stub!(:psc).and_return(psc)

      participant.person = person
      psc_participant.stub!(:participant).and_return(participant)
    end

    def expected_event_key(event_id)
      "#{ns}:psc_sync:event:#{event_id}"
    end

    def add_event_hash(event_id, start_date, overrides={})
      redis.hmset(expected_event_key(event_id), *{
          :status => 'new',
          :event_id => event_id,
          :start_date => start_date,
          :end_date => '',
          :recruitment_arm => 'hi',
          :sort_key => "#{start_date}:030"
        }.merge(overrides).to_a.flatten)
    end

    def update_event_hash(event_id, values={})
      redis.hmset(expected_event_key(event_id), *values.to_a.flatten)
    end

    # mini-integration tests; details are tested below
    describe '#import' do
      let(:scheduled_events) {
        [
          {
            :event_type_label => 'pregnancy_visit_1',
            :start_date => '2010-01-11',
            :scheduled_activities => %w(sa1)
          },
          {
            :event_type_label => 'birth',
            :start_date => '2011-03-09',
            :scheduled_activities => %w(sa3)
          }
        ]
      }

      let(:scheduled_activities) do
        {
          'sa1' => Psc::ScheduledActivity.new(
            :activity_id => 'sa1',
            :current_state => 'scheduled',
            :labels => 'event:pregnancy_visit_1'
          )
        }
      end

      before do
        psc_participant.stub!(:registered?).and_return(true)
        psc_participant.stub!(:append_study_segment)
        psc_participant.stub!(:scheduled_events).and_return([])
        psc_participant.stub!(:scheduled_activities).and_return(scheduled_activities)
        psc_participant.stub!(:update_scheduled_activity_states)

        redis.sadd("#{ns}:psc_sync:participants", p_id)

        add_event_hash('e1', '2010-01-11',
          :event_type_label => 'pregnancy_visit_1',
          :end_date => '2010-01-14')
        redis.sadd("#{ns}:psc_sync:p:#{p_id}:events", 'e1')

        add_link_contact_hash('e1_lc2', 'e1', '2010-01-12')
        redis.sadd(
          "#{ns}:psc_sync:p:#{p_id}:link_contacts:1.0:e1",
          'e1_lc2')
      end

      it 'schedules segments for events' do
        psc_participant.stub!(:scheduled_events).and_return([], scheduled_events)

        psc_participant.should_receive(:append_study_segment).with('2010-01-11', SEGMENT_IDS[:pv1])

        importer.import(responsible_user)
      end

      it 'updates activity states from linked contacts' do
        psc_participant.stub!(:scheduled_events).and_return(scheduled_events)

        psc_participant.should_receive(:update_scheduled_activity_states).with({
            'sa1' => {
              'state' => 'scheduled',
              'date' => '2010-01-12',
              'reason' => 'Imported new contact link e1_lc2.'
            }
          })

        importer.import(responsible_user)
      end

      it 'updates activity states for closed events' do
        psc_participant.stub!(:scheduled_events).and_return(scheduled_events)

        psc_participant.should_receive(:update_scheduled_activity_states).with({
            'sa1' => {
              'state' => 'canceled',
              'date' => '2010-01-14',
              'reason' => 'Imported closed event e1.'
            }
          })

        importer.import(responsible_user)
      end

      it 'creates events implied by the PSC events list' do
        psc_participant.stub!(:scheduled_events).and_return(scheduled_events)
        Event.should_receive(:create_placeholder_record).
          with(participant, '2011-03-09', 18, nil)

        importer.import(responsible_user)
      end

      it 'destroys the participants list' do
        importer.import(responsible_user)
        redis.smembers("#{ns}:psc_sync:participants").should == []
      end

      it 'copies the participants list to a backup key for reset' do
        importer.import(responsible_user)
        redis.smembers("#{ns}:psc_sync:participants_backup").should == [p_id]
      end

      it 'does not overwrite the backup if resuming from interrupted' do
        # simulated situation: participants p_id and "another" were
        # originally set to be syncd. Only "another" was before the
        # system was interrupted.
        redis.sadd("#{ns}:psc_sync:participants_backup", p_id)
        redis.sadd("#{ns}:psc_sync:participants_backup", 'another')

        importer.import(responsible_user)
        redis.smembers("#{ns}:psc_sync:participants_backup").sort.should == ['another', p_id]
      end

      it 'does not die if a participant has no events to sync' do
        redis.del "#{ns}:psc_sync:p:#{p_id}:events"
        psc_participant.stub!(:scheduled_events).and_return(scheduled_events)

        expect { importer.import(responsible_user) }.to_not raise_error
      end
    end

    describe '#reset' do
      before do
        redis.del("#{ns}:psc_sync:participants")
        redis.sadd("#{ns}:psc_sync:participants_backup", 'par-bar')
      end

      it 'copies the participant set back from the backup key' do
        importer.reset(responsible_user)

        redis.smembers("#{ns}:psc_sync:participants").should == %w(par-bar)
      end

      it 'does not blank out the participant list if reset twice' do
        importer.reset(responsible_user)
        importer.reset(responsible_user)

        redis.smembers("#{ns}:psc_sync:participants").should == %w(par-bar)
      end

      it 'does not blank out the participant list if reset without a backup' do
        redis.sadd("#{ns}:psc_sync:participants", 'par-quux')
        redis.del("#{ns}:psc_sync:participants_backup")

        importer.reset(responsible_user)

        redis.smembers("#{ns}:psc_sync:participants").should == %w(par-quux)
      end

      it "clears every participant's postnatal flag" do
        redis.set("#{ns}:psc_sync:p:gil:postnatal", 'true')

        importer.reset(responsible_user)

        redis.exists("#{ns}:psc_sync:p:gil:postnatal").should be_false
      end

      it "wipes every participant's events_order list" do
        redis.lpush("#{ns}:psc_sync:p:gil:events_order", 'a')

        importer.reset(responsible_user)

        redis.exists("#{ns}:psc_sync:p:gil:events_order").should be_false
      end

      %w(events_deferred events_unschedulable events_closed).each do |set|
        it "wipes every participant's #{set} set" do
          redis.sadd("#{ns}:psc_sync:p:gil:#{set}", 'a')

          importer.reset(responsible_user)

          redis.exists("#{ns}:psc_sync:p:gil:#{set}").should be_false
        end
      end

      describe 'and for' do
        let(:scheduled_events) {
          [
            {
              :event_type_label => 'birth',
              :start_date => '2010-09-30',
              :scheduled_activities => %w(sa1)
            },
            {
              :event_type_label => '3_month',
              :start_date => '2010-12-31',
              :scheduled_activities => %w(sa2)
            }
          ]
        }

        let(:scheduled_activities) do
          {
            'sa1' => Psc::ScheduledActivity.new(
              :activity_id => 'sa1',
              :current_state => 'scheduled',
              :labels => 'event:birth'
            )
          }
        end

        before do
          psc_participant.stub!(:registered?).and_return(true)
          psc_participant.stub!(:append_study_segment)
          psc_participant.stub!(:scheduled_events).and_return([])
          psc_participant.stub!(:scheduled_activities).and_return(scheduled_activities)
          psc_participant.stub!(:update_scheduled_activity_states)

          redis.sadd("#{ns}:psc_sync:participants", p_id)
          add_event_hash('e1', '2010-09-30',
            :event_type_label => 'birth',
            :end_date => '2010-09-30')
          redis.sadd("#{ns}:psc_sync:p:#{p_id}:events", 'e1')
        end

        describe 'placeholder events' do

          before(:each) do
            psc_participant.stub!(:scheduled_events).and_return(scheduled_events)
            with_versioning { importer.import(responsible_user) }
          end

          it 'deletes placeholder events created by import' do
            Event.where(:event_type_code => 23).size.should == 1

            importer.reset(responsible_user)

            Event.where(:event_type_code => 23).should == []
          end

          it 'does not delete other events' do
            with_versioning { Factory(:event) }
            Event.count.should == 2

            importer.reset(responsible_user)

            Event.count.should == 1
          end

          it 'does not fail when reset twice' do
            importer.reset(responsible_user)
            importer.reset(responsible_user)
          end
        end

        describe 'updated events' do
          before(:each) do
            Factory(:event, :participant => participant, :event_id => 'e1',
              :event_type_code => 18, :event_start_date => Date.new(2010, 10, 11))
            psc_participant.stub!(:scheduled_events).and_return(scheduled_events)
            with_versioning { importer.import(responsible_user) }
          end

          it 'update the affected event attribute updated by import' do
            Event.where(:event_type_code => 18).first.psc_ideal_date.to_s.should == '2010-09-30'

            importer.reset(responsible_user)

            Event.where(:event_type_code => 18).first.psc_ideal_date.to_s.should == '2010-10-11'
          end

          it 'does not fail when reset twice' do
            importer.reset(responsible_user)
            importer.reset(responsible_user)
          end
        end
      end
    end

    describe 'scheduling segments for events' do
      let(:unschedulable_key) { "#{ns}:psc_sync:p:#{p_id}:events_unschedulable" }

      before do
        psc_participant.stub!(:scheduled_events).and_return([{}])
        psc_participant.stub!(:registered?).and_return(true)
        psc_participant.stub!(:append_study_segment)

        redis.sadd("#{ns}:psc_sync:participants", p_id)
        %w(e10 e4 e1).each do |e|
          redis.sadd("#{ns}:psc_sync:p:#{p_id}:events", e)
        end
        add_event_hash('e4', '2010-04-04',
          :event_type_label => 'pregnancy_visit_2')
        add_event_hash('e1', '2010-01-11',
          :event_type_label => 'pregnancy_visit_1')
        add_event_hash('e10', '2010-10-10',
          :event_type_label => 'birth')
      end

      it 'schedules events in order by start date' do
        psc_participant.should_receive(:append_study_segment).
          with('2010-01-11', SEGMENT_IDS[:pv1]).ordered
        psc_participant.should_receive(:append_study_segment).
          with('2010-04-04', SEGMENT_IDS[:pv2]).ordered
        psc_participant.should_receive(:append_study_segment).
          with('2010-10-10', SEGMENT_IDS[:hi_child]).ordered

        importer.schedule_events(psc_participant)
      end

      describe 'when the participant has no PSC schedule' do
        it 'assigns the participant to the study in PSC using the event to find the first segment' do
          psc_participant.should_receive(:registered?).any_number_of_times.
            # first false, then true subsequent times
            and_return(false, true)

          psc_participant.should_receive(:register!).
            with('2010-01-11', SEGMENT_IDS[:pv1])

          importer.schedule_events(psc_participant)
        end
      end

      describe 'when the event already has scheduled activities' do
        let(:recruitment_arm) { 'hi' }

        before do
          psc_participant.stub!(:scheduled_events).and_return([{
                :event_type_label => event_type_label,
                :start_date => start_date,
                :scheduled_activities => ['dc']
              }])

          add_event_hash('e1', '2010-01-11',
            :event_type_label => event_type_label, :recruitment_arm => recruitment_arm)
        end

        shared_examples_for 'a new event' do
          it 'schedules a new segment' do
            psc_participant.should_receive(:append_study_segment).
              with('2010-01-11', candidate_segment)

            importer.schedule_events(psc_participant)
          end
        end

        shared_examples_for 'an already scheduled event' do
          it 'does not schedule a new segment' do
            psc_participant.should_not_receive(:append_study_segment).
              with('2010-01-11', candidate_segment)

            importer.schedule_events(psc_participant)
          end
        end

        describe 'and the event type is repeatable' do
          let(:recruitment_arm) { 'lo' }
          let(:event_type_label) { 'low_to_high_conversion' }
          let(:candidate_segment) { SEGMENT_IDS[:lo_hi_conversion] }

          describe 'and the activity ideal date is 15 days before the event start date' do
            let(:start_date) { '2009-12-27' }

            it_behaves_like 'a new event'
          end

          describe 'and the activity ideal date is 14 days before the event start date' do
            let(:start_date) { '2009-12-28' }

            it_behaves_like 'an already scheduled event'
          end

          describe 'and the activity ideal date is the same as the event start date' do
            let(:start_date) { '2010-01-11' }

            it_behaves_like 'an already scheduled event'
          end

          describe 'and the activity ideal date is 14 days after the event start date' do
            let(:start_date) { '2010-01-25' }

            it_behaves_like 'an already scheduled event'
          end

          describe 'and the activity ideal date is 15 days after the event start date' do
            let(:start_date) { '2010-01-26' }

            it_behaves_like 'a new event'
          end
        end

        describe 'and the event type is not repeatable' do
          let(:event_type_label) { 'pregnancy_visit_1' }
          let(:candidate_segment) { SEGMENT_IDS[:pv1] }

          describe 'and the activity ideal date is far before before the event start date' do
            let(:start_date) { '1906-12-27' }

            it_behaves_like 'an already scheduled event'
          end

          describe 'and the activity ideal date is 15 days before the event start date' do
            let(:start_date) { '2009-12-27' }

            it_behaves_like 'an already scheduled event'
          end

          describe 'and the activity ideal date is 14 days before the event start date' do
            let(:start_date) { '2009-12-28' }

            it_behaves_like 'an already scheduled event'
          end

          describe 'and the activity ideal date is the same as the event start date' do
            let(:start_date) { '2010-01-11' }

            it_behaves_like 'an already scheduled event'
          end

          describe 'and the activity ideal date is 14 days after the event start date' do
            let(:start_date) { '2010-01-25' }

            it_behaves_like 'an already scheduled event'
          end

          describe 'and the activity ideal date is 15 days after the event start date' do
            let(:start_date) { '2010-01-26' }

            it_behaves_like 'an already scheduled event'
          end

          describe 'and the activity ideal date is far beyond the event start date' do
            let(:start_date) { '2525-01-26' }

            it_behaves_like 'an already scheduled event'
          end

          describe 'for existing event' do
            let(:start_date) { '2010-01-26' }

            it_behaves_like 'an already scheduled event'

            it "does update the event psc_ideal_date to the activity ideal date" do
              Factory(:event, :participant => participant, :event_id => 'e1',
              :event_type_code => 13, :event_start_date => Date.new(2010, 01, 11))

              importer.schedule_events(psc_participant)
              participant.events.where(:event_type_code => 13).first.psc_ideal_date.to_s.should == '2010-01-26'
            end
          end
        end
      end

      describe 'when there is no existing segment with a matching type and date' do
        describe 'when the event type is birth' do
          before do
            psc_participant.stub!(:append_study_segment)
          end

          it 'schedules the lo birth segment when the participant is lo' do
            redis.hset "#{ns}:psc_sync:event:e10", "recruitment_arm", "lo"
            psc_participant.should_receive(:append_study_segment).
              with('2010-10-10', SEGMENT_IDS[:lo_birth]).ordered

            importer.schedule_events(psc_participant)
          end

          it 'schedules the hi birth segment when the participant is hi' do
            redis.hset "#{ns}:psc_sync:event:e10", "recruitment_arm", "hi"
            psc_participant.should_receive(:append_study_segment).
              with('2010-10-10', SEGMENT_IDS[:hi_child]).ordered

            importer.schedule_events(psc_participant)
          end
        end

        describe 'when there are multiple candidate segments' do
          before do
            # Since informed consent was removed from the template as a separate
            # event as part of #2709, there are no practical examples of events
            # with ambiguous segment mappings.
            #
            # Since it's the sort of thing that could come back, however, I
            # don't want to remove the code that handles it.
            pending 'No practical examples of this'

            add_event_hash('e2', '2010-01-11',
              :sort_key => '2010-01-11:010',
              :event_type_label => 'informed_consent')
            redis.sadd("#{ns}:psc_sync:p:#{p_id}:events", 'e2')
          end

          it 'defers the decision until later then uses an existing segment' do
            psc_participant.should_receive(:scheduled_events).exactly(5).times.and_return(
              [], [], [], [],
              [{ :event_type_label => 'informed_consent', :start_date => '2010-01-01' }]
            )

            importer.schedule_events(psc_participant)

            redis.smembers(unschedulable_key).should == []
          end

          it 'registers events that were never syncable' do
            psc_participant.should_receive(:scheduled_events).exactly(5).times.and_return([])

            importer.schedule_events(psc_participant)

            redis.smembers(unschedulable_key).should == %w(e2)
          end
        end

        describe 'when a lo participant with both pre and post natal quexes' do
          before do
            redis.del("#{ns}:psc_sync:p:#{p_id}:events")
            %w(e11 e5 e2).each do |e|
              redis.sadd("#{ns}:psc_sync:p:#{p_id}:events", e)
            end
            add_event_hash('e5', '2010-04-04',
              :event_type_label => 'birth', :recruitment_arm => 'lo')
            add_event_hash('e2', '2010-01-11',
              :event_type_label => 'low_intensity_data_collection', :recruitment_arm => 'lo')
            add_event_hash('e11', '2010-10-10',
              :event_type_label => 'low_intensity_data_collection', :recruitment_arm => 'lo')
          end

          it 'schedules the correct segments before and after the birth event' do
            psc_participant.should_receive(:append_study_segment).
              with('2010-01-11', SEGMENT_IDS[:lo_ppg_12]).ordered
            psc_participant.should_receive(:append_study_segment).
              with('2010-04-04', SEGMENT_IDS[:lo_birth]).ordered
            psc_participant.should_receive(:append_study_segment).
              with('2010-10-10', SEGMENT_IDS[:lo_postnatal]).ordered

            importer.schedule_events(psc_participant)
          end
        end

        describe 'when a PBS screener' do
          let(:screener_event_id) { 'escr' }

          before do
            redis.del("#{ns}:psc_sync:p:#{p_id}:events")
            redis.sadd("#{ns}:psc_sync:p:#{p_id}:events", screener_event_id)
            add_event_hash(screener_event_id, '2010-04-04',
              :event_type_label => 'pbs_participant_eligibility_screening')
          end

          shared_examples_for 'PSC sync for eligibility screener' do
            # expected let: expected_segment_id

            it 'schedules the appropriate segment' do
              psc_participant.should_receive(:append_study_segment).
                with('2010-04-04', expected_segment_id)

              importer.schedule_events(psc_participant)
            end

            it 'registers no ambiguous segments' do
              importer.schedule_events(psc_participant)

              redis.smembers(unschedulable_key).should == []
            end
          end

          describe 'at the pre-natal provider' do
            include_context 'PSC sync for eligibility screener'

            let(:expected_segment_id) { SEGMENT_IDS[:pbs_provider_screening] }

            before do
              update_event_hash(screener_event_id, :pbs_birth_cohort => false)
            end
          end

          describe 'at the birthing hospital' do
            include_context 'PSC sync for eligibility screener'

            let(:expected_segment_id) { SEGMENT_IDS[:pbs_hospital_screening] }

            before do
              update_event_hash(screener_event_id, :pbs_birth_cohort => true)
            end
          end
        end

        describe 'when a hi participant with a lo-only event' do
          before do
            redis.del("#{ns}:psc_sync:p:#{p_id}:events")
            %w(e7 e15).each do |e|
              redis.sadd("#{ns}:psc_sync:p:#{p_id}:events", e)
            end
            add_event_hash('e15', '2010-01-11',
              :event_type_label => 'low_intensity_data_collection', :recruitment_arm => 'hi')
            add_event_hash('e7', '2010-04-07',
              :event_type_label => 'birth', :recruitment_arm => 'hi')
          end

          it 'does not schedule the lo segment' do
            psc_participant.should_not_receive(:append_study_segment).
              with('2010-01-11', SEGMENT_IDS[:lo_ppg_12])

            importer.schedule_events(psc_participant)

            redis.smembers(unschedulable_key).should == %w(e15)
          end

          it 'schedules the hi segments' do
            psc_participant.should_receive(:append_study_segment).
              with('2010-04-07', SEGMENT_IDS[:hi_child])

            importer.schedule_events(psc_participant)
          end
        end

        describe 'when a lo participant with a hi-only event' do
          before do
            %w(e4 e1 e10).each do |e|
              update_event_hash(e, :recruitment_arm => 'lo')
            end
          end

          it 'does not schedule the hi segments' do
            psc_participant.should_not_receive(:append_study_segment).
              with('2010-01-11', SEGMENT_IDS[:pv1])
            psc_participant.should_not_receive(:append_study_segment).
              with('2010-04-04', SEGMENT_IDS[:pv2])

            importer.schedule_events(psc_participant)

            redis.smembers(unschedulable_key).sort.should == %w(e1 e4)
          end

          it 'schedules lo segments' do
            psc_participant.should_receive(:append_study_segment).
              with('2010-10-10', SEGMENT_IDS[:lo_birth])

            importer.schedule_events(psc_participant)
          end
        end
      end

      it 'queues a closed event for later close processing' do
        redis.hset("#{ns}:psc_sync:event:e4", 'end_date', '2010-04-07')

        importer.schedule_events(psc_participant)

        redis.smembers("#{ns}:psc_sync:p:#{p_id}:events_closed").should == %w(e4)
      end
    end

    def add_link_contact_hash(lc_id, event_id, contact_date, overrides={})
      key = "#{ns}:psc_sync:link_contact:#{lc_id}"
      redis.hmset(key, *{
          :link_contact_id => lc_id,
          :event_id => event_id,
          :contact_date => contact_date,
          :sort_key => "#{event_id}:#{contact_date}",
          :status => 'new'
        }.merge(overrides).to_a.flatten)
    end

    describe 'updating open activities for contact links' do
      before do
        add_event_hash('e1', '2010-01-11',
          :event_type_label => 'pregnancy_visit_1')
        add_link_contact_hash('e1_lc1', 'e1', '2010-01-11')
        add_link_contact_hash('e1_lc2', 'e1', '2010-01-12')
        add_link_contact_hash('e1_lc3', 'e1', '2010-01-18')

        add_event_hash('e2', '2010-04-01',
          :event_type_label => 'pregnancy_visit_2')
        add_link_contact_hash('e2_lc4', 'e2', '2010-04-04')
        add_link_contact_hash('e2_lc5', 'e2', '2010-04-06')

        psc_participant.stub!(:scheduled_events).and_return(scheduled_events)
        psc_participant.stub!(:scheduled_activities).and_return(scheduled_activities)
        psc_participant.stub!(:update_scheduled_activity_states)

        {
          'e1' => %w(e1_lc3 e1_lc2 e1_lc1),
          'e2' => %w(e2_lc4 e2_lc5)
        }.each do |event_id, lc_ids|
          lc_ids.each do |lc_id|
            redis.sadd(
              "#{ns}:psc_sync:p:#{p_id}:link_contacts:#{event_id}",
              lc_id)
          end
        end

        redis.sadd("#{ns}:psc_sync:p:#{p_id}:link_contact_updated_scheduled_activities", 'sa3')
      end

      let(:scheduled_events) {
        [
          {
            :event_type_label => 'pregnancy_visit_1',
            :start_date => '2010-01-11',
            :scheduled_activities => %w(sa1 sa3 sa4)
          },
          {
            :event_type_label => 'pregnancy_visit_2',
            :start_date => '2010-04-04',
            :scheduled_activities => %w(sa2 sa5)
          }
        ]
      }

      let(:scheduled_activities) {
        {
          'sa1' => Psc::ScheduledActivity.new(
            :current_state => 'scheduled',
            :labels => 'event:pregnancy_visit_1'
          ),
          'sa2' => Psc::ScheduledActivity.new(
            :current_state => 'scheduled',
            :labels => 'event:pregnancy_visit_2'
          ),
          'sa3' => Psc::ScheduledActivity.new(
            :current_state => 'scheduled',
            :labels => 'event:pregnancy_visit_1 instrument:2.0:ins_que_pregvisit1_int_ehpbhi_p2_v2.0'
          ),
          'sa4' => Psc::ScheduledActivity.new(
            :current_state => 'scheduled',
            :labels => 'event:pregnancy_visit_1'
          ),
          'sa5' => Psc::ScheduledActivity.new(
            :current_state => 'canceled',
            :labels => 'event:pregnancy_visit_2'
          )
        }
      }

      it 'batch updates all SAs at each LC' do
        psc_participant.should_receive(:update_scheduled_activity_states).with(
          'sa1' => { 'date' => '2010-01-11', 'reason' => 'Imported new contact link e1_lc1.', 'state' => 'scheduled' },
          'sa4' => { 'date' => '2010-01-11', 'reason' => 'Imported new contact link e1_lc1.', 'state' => 'scheduled' }
          ).ordered
        psc_participant.should_receive(:update_scheduled_activity_states).with(
          'sa1' => { 'date' => '2010-01-12', 'reason' => 'Imported new contact link e1_lc2.', 'state' => 'scheduled' },
          'sa4' => { 'date' => '2010-01-12', 'reason' => 'Imported new contact link e1_lc2.', 'state' => 'scheduled' }
          ).ordered
        psc_participant.should_receive(:update_scheduled_activity_states).with(
          'sa1' => { 'date' => '2010-01-18', 'reason' => 'Imported new contact link e1_lc3.', 'state' => 'scheduled' },
          'sa4' => { 'date' => '2010-01-18', 'reason' => 'Imported new contact link e1_lc3.', 'state' => 'scheduled' }
          ).ordered
        psc_participant.should_receive(:update_scheduled_activity_states).with(
          'sa2' => { 'date' => '2010-04-04', 'reason' => 'Imported new contact link e2_lc4.', 'state' => 'scheduled' }
          ).ordered

        importer.update_sa_histories(psc_participant)
      end
    end

    describe 'canceling incomplete activities for closed events' do
      before do
        add_event_hash('e1', '2010-01-11',
          :event_type_label => 'pregnancy_visit_1',
          :end_date => '2010-01-22')
        add_event_hash('e2', '2010-04-4',
          :event_type_label => 'pregnancy_visit_2')

        redis.sadd("#{ns}:psc_sync:p:#{p_id}:events_closed", 'e1')

        psc_participant.stub!(:scheduled_events).and_return(scheduled_events)
        psc_participant.stub!(:scheduled_activities).and_return(scheduled_activities)
        psc_participant.stub!(:update_scheduled_activity_states)
      end

      let(:scheduled_events) {
        [
          {
            :event_type_label => 'pregnancy_visit_1',
            :start_date => '2010-01-11',
            :scheduled_activities => %w(sa1 sa3)
          },
          {
            :event_type_label => 'pregnancy_visit_2',
            :start_date => '2010-04-04',
            :scheduled_activities => %w(sa2)
          }
        ]
      }

      let(:scheduled_activities) {
        {
          'sa1' => Psc::ScheduledActivity.new(
            :activity_id => 'sa1',
            :current_state => 'scheduled',
            :labels => 'event:pregnancy_visit_1'
          ),
          'sa2' => Psc::ScheduledActivity.new(
            :activity_id => 'sa2',
            :current_state => 'scheduled',
            :labels => 'event:pregnancy_visit_2'
          ),
          'sa3' => Psc::ScheduledActivity.new(
            :activity_id => 'sa3',
            :current_state => 'occurred',
            :labels => 'event:pregnancy_visit_1 instrument:2.0:ins_que_pregvisit1_int_ehpbhi_p2_v2.0'
          )
        }
      }

      it 'uses the full schedule content' do
        psc_participant.should_receive(:scheduled_activities).once.with(:sa_content)

        importer.close_pending_activities_for_closed_events(psc_participant)
      end

      it 'does not load the full schedule if there are no closed events' do
        redis.del("#{ns}:psc_sync:p:#{p_id}:events_closed")

        psc_participant.should_not_receive(:scheduled_activities)

        importer.close_pending_activities_for_closed_events(psc_participant)
      end

      it 'cancels activities for closed, incomplete events' do
        psc_participant.should_receive(:update_scheduled_activity_states).once do |arg|
          arg.keys.should == %w(sa1) # not sa2
        end

        importer.close_pending_activities_for_closed_events(psc_participant)
      end

      {
        'scheduled' => 'canceled',
        'conditional' => 'NA'
      }.each do |in_state, out_state|
        it "makes a '#{in_state}' activity '#{out_state}'" do
          scheduled_activities['sa1'].current_state = in_state

          psc_participant.should_receive(:update_scheduled_activity_states).once.with({
              'sa1' => {
                'date' => '2010-01-22',
                'reason' => 'Imported closed event e1.',
                'state' => out_state
              }
            })

          importer.close_pending_activities_for_closed_events(psc_participant)
        end
      end

      %w(occurred canceled missed NA).each do |closed_state|
        it "does not change the state of a '#{closed_state}' activity" do
          scheduled_activities['sa1'].current_state = closed_state

          psc_participant.should_not_receive(:update_scheduled_activity_states)

          importer.close_pending_activities_for_closed_events(psc_participant)
        end
      end
    end

    describe 'for completed events' do
      before do
        add_event_hash('e1', '2010-01-11',
          :event_type_label => 'pregnancy_visit_1',
          :end_date => '2010-01-22',
          :completed => true)

        redis.sadd("#{ns}:psc_sync:p:#{p_id}:events_closed", 'e1')

        psc_participant.stub!(:scheduled_events).and_return(scheduled_events)
        psc_participant.stub!(:scheduled_activities).and_return(scheduled_activities)
        psc_participant.stub!(:update_scheduled_activity_states)
      end

      let(:scheduled_events) {
        [
          {
            :event_type_label => 'pregnancy_visit_1',
            :start_date => '2010-01-11',
            :scheduled_activities => %w(sa1)
          }
        ]
      }

      let(:scheduled_activities) {
        {
          'sa1' => Psc::ScheduledActivity.new(
            :activity_id => 'sa1',
            :current_state => 'scheduled',
            :labels => 'event:pregnancy_visit_1'
          )
        }
      }

      it 'marks the corresponding activities as occurred' do
        psc_participant.should_receive(:update_scheduled_activity_states).once.with({
          'sa1' => {
            'date' => '2010-01-22',
            'reason' => 'Imported closed event e1.',
            'state' => 'occurred'
          }
        })

        importer.close_pending_activities_for_closed_events(psc_participant)
      end

      describe 'corresponding to conditional activities' do
        before do
          scheduled_activities['sa1'].current_state = 'conditional'
        end

        it 'marks the corresponding activities as occurred' do
          psc_participant.should_receive(:update_scheduled_activity_states).once.with({
            'sa1' => {
              'date' => '2010-01-22',
              'reason' => 'Imported closed event e1.',
              'state' => 'occurred'
            }
          })

          importer.close_pending_activities_for_closed_events(psc_participant)
        end
      end
    end

    describe 'creating new events implied by PSC' do
      let(:scheduled_events) {
        [
          {
            :event_type_label => 'father',
            :start_date => '2009-06-21',
            :scheduled_activities => %w(sa0)
          },
          {
            :event_type_label => 'birth',
            :start_date => '2010-09-30',
            :scheduled_activities => %w(sa1)
          },
          {
            :event_type_label => '3_month',
            :start_date => '2010-12-31',
            :scheduled_activities => %w(sa2)
          },
          {
            :event_type_label => '6_month',
            :start_date => '2011-03-16',
            :scheduled_activities => %w(sa3)
          },
          {
            :event_type_label => 'informed_consent',
            :start_date => '2011-06-11',
            :scheduled_activities => %w(sa7)
          },
          {
            # can't find way to load different mdes version until #2496 is done
            :event_type_label => 'non_mdes_event',
            :start_date => '2013-03-16',
            :scheduled_activities => %w(sa8)
          }
        ]
      }

      let(:scheduled_activities) do
        {
          'sa1' => Psc::ScheduledActivity.new(
            :activity_id => 'sa1',
            :current_state => 'scheduled',
            :labels => 'event:birth'
          )
        }
      end

      before do
        psc_participant.stub!(:registered?).and_return(true)
        psc_participant.stub!(:append_study_segment)
        psc_participant.stub!(:scheduled_events).and_return([])
        psc_participant.stub!(:scheduled_activities).and_return(scheduled_activities)
        psc_participant.stub!(:update_scheduled_activity_states)

        redis.sadd("#{ns}:psc_sync:participants", p_id)
        add_event_hash('e1', '2010-09-30',
          :event_type_label => 'birth',
          :end_date => '2010-09-30')
        redis.sadd("#{ns}:psc_sync:p:#{p_id}:events", 'e1')

        # 6 month already exists
        Factory(:event, :participant => participant,
          :event_type_code => 24, :event_start_date => Date.new(2011, 3, 16))
        psc_participant.stub!(:scheduled_events).and_return(scheduled_events)
        with_versioning { importer.import(responsible_user) }
      end

      it 'does not create events for PSC events that are earlier than some imported event' do
        # father
        participant.events.where(:event_type_code => 19).should == []
      end

      it 'does not create events for PSC informed consent events' do
        participant.events.where(:event_type_code => 10).should == []
      end

      it 'does not create duplicate events for PSC events which correspond to imported core events' do
        # birth
        participant.events.where(:event_type_code => 18).should == []
      end

      it 'creates placeholders for PSC events that are later than all imported events' do
        # 3 month
        participant.events.where(:event_type_code => 23).first.
          event_start_date.to_s.should == '2010-12-31'
      end

      it 'does not create placeholders for PSC events that already exist in Cases' do
        # 6 month
        participant.events.where(:event_type_code => 24).count.should == 1
      end

      it 'does not create placeholders for PSC events that do not exist in the particular MDES version in Cases' do
        # does not create any event for non-matching mdes version
        participant.events.count.should == 2
      end

      it 'assigns change responsibility to the given user' do
        versions = Version.where(:item_id => participant.event_ids, :item_type => Event.to_s)
        versions.map(&:whodunnit).uniq.should == [responsible_user]
      end
    end
  end
end
