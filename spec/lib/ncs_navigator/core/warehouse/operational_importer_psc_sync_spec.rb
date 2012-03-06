require 'spec_helper'
require Rails.root + 'spec/warehouse_setup'

require 'ncs_navigator/core/warehouse'

module NcsNavigator::Core::Warehouse
  describe OperationalImporterPscSync do
    include NcsNavigator::Core::Spec::WarehouseSetup

    SEGMENT_IDS = {
      :pv1 => 'ca65bbbb-7e47-4f71-a4f0-071e7f73f380',
      :pv2 => 'cef89a1e-5a08-4d94-811d-1aea62700d61',
      :hi_child => '072db970-d32a-4006-83b0-3f0240833894',
      :lo_birth => '53318f20-d21f-452e-a8e8-3f2ed6bb6c93'
    }

    let(:redis) { Rails.application.redis }
    let(:ns) { 'NcsNavigator::Core::Warehouse::OperationalImporter' }

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

    def add_event_hash(event_id, start_date, overrides={})
      key = "#{ns}:psc_sync:event:#{event_id}"
      redis.hmset(key, *{
          :status => 'new',
          :event_id => event_id,
          :start_date => start_date,
          :end_date => '',
          :sort_key => "#{start_date}:030"
        }.merge(overrides).to_a.flatten)
    end

    # mini-integration tests; details are tested below
    describe '#import' do
      let(:scheduled_events) {
        [ {
            :event_type_label => 'pregnancy_visit_1',
            :start_date => '2010-01-11',
            :scheduled_activities => %w(sa1)
          } ]
      }

      let(:scheduled_activities) {
        {
          'sa1' => {
            'id' => 'sa1',
            'current_state' => { 'name' => 'scheduled' },
            'labels' => 'event:pregnancy_visit_1'
          }
        }
      }

      before do
        participant.stub!(:low_intensity?).and_return(false)

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
          "#{ns}:psc_sync:p:#{p_id}:link_contacts_without_instrument:e1",
          'e1_lc2')
      end

      it 'schedules segments for events' do
        psc_participant.stub!(:scheduled_events).and_return([], scheduled_events)

        psc_participant.should_receive(:append_study_segment).with('2010-01-11', SEGMENT_IDS[:pv1])

        importer.import
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

        importer.import
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

        importer.import
      end
    end

    describe 'scheduling segments for events' do
      before do
        participant.stub!(:low_intensity?).and_return(false)

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
        shared_examples_for 'a new event' do
          before do
            psc_participant.stub!(:scheduled_events).and_return([{
                  :event_type_label => 'pregnancy_visit_1',
                  :start_date => start_date,
                  :scheduled_activities => ['dc']
                }])
          end

          it 'schedules a new segment' do
            psc_participant.should_receive(:append_study_segment).
              with('2010-01-11', SEGMENT_IDS[:pv1])

            importer.schedule_events(psc_participant)
          end
        end

        shared_examples_for 'an already scheduled event' do
          before do
            psc_participant.stub!(:scheduled_events).and_return([{
                  :event_type_label => 'pregnancy_visit_1',
                  :start_date => start_date,
                  :scheduled_activities => ['dc']
                }])
          end

          it 'does not schedule a new segment' do
            psc_participant.should_not_receive(:append_study_segment).
              with('2010-01-11', SEGMENT_IDS[:pv1])

            importer.schedule_events(psc_participant)
          end
        end

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

      describe 'when there is no existing segment with a matching type and date' do
        describe 'when the event type is birth' do
          before do
            psc_participant.stub!(:append_study_segment)
          end

          it 'schedules the lo birth segment when the participant is lo' do
            participant.should_receive(:low_intensity?).at_least(:once).and_return(true)
            psc_participant.should_receive(:append_study_segment).
              with('2010-10-10', SEGMENT_IDS[:lo_birth]).ordered

            importer.schedule_events(psc_participant)
          end

          it 'schedules the hi birth segment when the participant is hi' do
            participant.should_receive(:low_intensity?).and_return(false)
            psc_participant.should_receive(:append_study_segment).
              with('2010-10-10', SEGMENT_IDS[:hi_child]).ordered

            importer.schedule_events(psc_participant)
          end
        end

        describe 'when there are multiple candidate segments' do
          let(:unschedulable_key) { "#{ns}:psc_sync:p:#{p_id}:events_unschedulable" }

          before do
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

    describe 'updating activities for contact links' do
      before do
        add_event_hash('e1', '2010-01-11',
          :event_type_label => 'pregnancy_visit_1')
        add_link_contact_hash('e1_lc1', 'e1', '2010-01-11')
        add_link_contact_hash('e1_lc2', 'e1', '2010-01-12')
        add_link_contact_hash('e1_lc3', 'e1', '2010-01-18')

        instrument_props = {
          :instrument_id => 'e1_i1',
          :instrument_status => 'partial',
          :instrument_type => '9'
        }
        add_link_contact_hash('e1_lc1i', 'e1', '2010-01-11', instrument_props)
        add_link_contact_hash('e1_lc2i', 'e1', '2010-01-12', instrument_props)
        add_link_contact_hash('e1_lc3i', 'e1', '2010-01-18', instrument_props)

        add_event_hash('e2', '2010-04-01',
          :event_type_label => 'pregnancy_visit_2')
        add_link_contact_hash('e2_lc4', 'e2', '2010-04-04')

        psc_participant.stub!(:scheduled_events).and_return(scheduled_events)
        psc_participant.stub!(:scheduled_activities).and_return(scheduled_activities)
        psc_participant.stub!(:update_scheduled_activity_states)
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
            :scheduled_activities => %w(sa2)
          }
        ]
      }

      let(:scheduled_activities) {
        {
          'sa1' => {
            'current_state' => { 'name' => 'scheduled' },
            'labels' => 'event:pregnancy_visit_1'
          },
          'sa2' => {
            'current_state' => { 'name' => 'scheduled' },
            'labels' => 'event:pregnancy_visit_2'
          },
          'sa3' => {
            'current_state' => { 'name' => 'scheduled' },
            'labels' => 'event:pregnancy_visit_1 instrument:ins_que_pregvisit1_int_ehpbhi_p2_v2.0'
          },
          'sa4' => {
            'current_state' => { 'name' => 'scheduled' },
            'labels' => 'event:pregnancy_visit_1'
          }
        }
      }

      describe 'for contact links with instruments' do
        before do
          %w(e1_lc1i e1_lc3i e1_lc2i).each do |lc_id|
            redis.sadd("#{ns}:psc_sync:p:#{p_id}:link_contacts_with_instrument:e1_i1", lc_id)
          end
        end

        it 'uses the sa_list only' do
          psc_participant.should_receive(:scheduled_activities).at_least(:once).with(:sa_list)
          psc_participant.should_not_receive(:scheduled_activities).with(:sa_activities)
          psc_participant.should_not_receive(:scheduled_activities).with

          importer.update_sa_histories(psc_participant)
        end

        describe 'when a matching SA exists' do
          it 'updates the SA once for each LC in order' do
            psc_participant.should_receive(:update_scheduled_activity_states).with(
              'sa3' => { 'date' => '2010-01-11', 'reason' => 'Imported new contact link e1_lc1i.', 'state' => 'scheduled' }).
              ordered
            psc_participant.should_receive(:update_scheduled_activity_states).with(
              'sa3' => { 'date' => '2010-01-12', 'reason' => 'Imported new contact link e1_lc2i.', 'state' => 'scheduled' }).
              ordered
            psc_participant.should_receive(:update_scheduled_activity_states).with(
              'sa3' => { 'date' => '2010-01-18', 'reason' => 'Imported new contact link e1_lc3i.', 'state' => 'scheduled' }).
              ordered

            importer.update_sa_histories(psc_participant)
          end

          it 'closes the SA when completed' do
            %w(e1_lc1i e1_lc2i e1_lc3i).each do |lc_id|
              redis.hset("#{ns}:psc_sync:link_contact:#{lc_id}", 'instrument_status', 'completed')
            end

            psc_participant.should_receive(:update_scheduled_activity_states).with(
              'sa3' => { 'date' => '2010-01-18', 'reason' => 'Imported completed instrument e1_i1.', 'state' => 'occurred' })

            importer.update_sa_histories(psc_participant)
          end

          it 'records the SA as handled' do
            importer.update_sa_histories(psc_participant)

            redis.smembers("#{ns}:psc_sync:p:#{p_id}:link_contact_updated_scheduled_activities").
              should == %w(sa3)
          end
        end

        describe 'when no matching SA exists' do
          before do
            scheduled_activities['sa3']['labels'] = 'event:pregnancy_visit_1'
          end

          it 'does not update the SA' do
            psc_participant.should_not_receive(:update_scheduled_activity_states).with(
              'sa3' => { 'date' => '2010-01-11', 'reason' => 'Imported new contact link e1_lc1i.', 'state' => 'scheduled' }
            )

            importer.update_sa_histories(psc_participant)
          end

          it 'does not issue an empty update to PSC' do
            psc_participant.should_not_receive(:update_scheduled_activity_states).with({})

            importer.update_sa_histories(psc_participant)
          end

          it 'does not record the SA as handled' do
            redis.smembers("#{ns}:psc_sync:p:#{p_id}:link_contact_updated_scheduled_activities").
              should == []
          end
        end
      end

      describe 'for contact links without instruments' do
        before do
          {
            'e1' => %w(e1_lc3 e1_lc2 e1_lc1),
            'e2' => %w(e2_lc4)
          }.each do |event_id, lc_ids|
            lc_ids.each do |lc_id|
              redis.sadd(
                "#{ns}:psc_sync:p:#{p_id}:link_contacts_without_instrument:#{event_id}",
                lc_id)
            end
          end

          redis.sadd("#{ns}:psc_sync:p:#{p_id}:link_contact_updated_scheduled_activities", 'sa3')
        end

        it 'uses the sa_list only' do
          psc_participant.should_receive(:scheduled_activities).at_least(:once).with(:sa_list)
          psc_participant.should_not_receive(:scheduled_activities).with(:sa_activities)
          psc_participant.should_not_receive(:scheduled_activities).with # nothing

          importer.update_sa_histories(psc_participant)
        end

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
          'sa1' => {
            'id' => 'sa1',
            'current_state' => { 'name' => 'scheduled' },
            'labels' => 'event:pregnancy_visit_1'
          },
          'sa2' => {
            'id' => 'sa2',
            'current_state' => { 'name' => 'scheduled' },
            'labels' => 'event:pregnancy_visit_2'
          },
          'sa3' => {
            'id' => 'sa3',
            'current_state' => { 'name' => 'occurred' },
            'labels' => 'event:pregnancy_visit_1 instrument:ins_que_pregvisit1_int_ehpbhi_p2_v2.0'
          },
        }
      }

      it 'uses the full schedule content' do
        psc_participant.should_receive(:scheduled_activities).once.with(:sa_content)

        importer.cancel_pending_activities_for_closed_events(psc_participant)
      end

      it 'does not load the full schedule if there are no closed events' do
        redis.del("#{ns}:psc_sync:p:#{p_id}:events_closed")

        psc_participant.should_not_receive(:scheduled_activities)

        importer.cancel_pending_activities_for_closed_events(psc_participant)
      end

      it 'only cancels activities for closed events' do
        psc_participant.should_receive(:update_scheduled_activity_states).once do |arg|
          arg.keys.should == %w(sa1) # not sa2
        end

        importer.cancel_pending_activities_for_closed_events(psc_participant)
      end

      {
        'scheduled' => 'canceled',
        'conditional' => 'NA',
      }.each do |in_state, out_state|
        it "makes a '#{in_state}' activity '#{out_state}'" do
          scheduled_activities['sa1']['current_state']['name'] = in_state

          psc_participant.should_receive(:update_scheduled_activity_states).once.with({
              'sa1' => {
                'date' => '2010-01-22',
                'reason' => 'Imported closed event e1.',
                'state' => out_state
              }
            })

          importer.cancel_pending_activities_for_closed_events(psc_participant)
        end
      end

      %w(occurred canceled missed NA).each do |closed_state|
        it "does not change the state of a '#{closed_state}' activity" do
          scheduled_activities['sa1']['current_state']['name'] = closed_state

          psc_participant.should_not_receive(:update_scheduled_activity_states)

          importer.cancel_pending_activities_for_closed_events(psc_participant)
        end
      end
    end
  end
end
