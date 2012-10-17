require 'logger'
require 'set'
require 'spec_helper'
require 'stringio'

module Field
  describe PscSync do
    let(:e1) { Factory(:event, :participant => p1) }
    let(:e2) { Factory(:event, :participant => p2) }
    let(:instrument) { Factory(:instrument, :event => e2) }
    let(:p1) { Factory(:participant) }
    let(:p2) { Factory(:participant) }
    let(:person1) { Factory(:person) }
    let(:person2) { Factory(:person) }

    let(:sio) { StringIO.new }
    let(:log) { sio.string }
    let(:logger) { ::Logger.new(sio) }

    let(:sp) { stub }
    let(:sync) { PscSync.new }

    before do
      Factory(:participant_person_link, :participant_id => p1.id, :person_id => person1.id)
      Factory(:participant_person_link, :participant_id => p2.id, :person_id => person2.id)

      sp.stub!(:current_events => [e1, e2], :current_instruments => [instrument])

      sync.psc = stub.as_null_object
      sync.superposition = sp
      sync.logger = logger
    end

    describe '#resolve_psc_participants' do
      before do
        sync.resolve_psc_participants
      end

      it 'builds one PscParticipant per event participant' do
        sync.psc_participants.detect { |_, pscp| pscp.participant == e1.participant }.should_not be_nil
        sync.psc_participants.detect { |_, pscp| pscp.participant == e2.participant }.should_not be_nil
      end

      it 'builds one PscParticipant per instrument participant' do
        sync.psc_participants.detect { |_, pscp| pscp.participant == instrument.participant }.should_not be_nil
      end
    end

    describe '#grouped_event_sas' do
      let(:sas) { sync.grouped_event_sas }
      let(:pscp_e1) { sync.psc_participants[e1.participant.id] }
      let(:pscp_e2) { sync.psc_participants[e2.participant.id] }
      let(:sas_e1) { [Psc::ScheduledActivity.new(:activity_id => 'foo')] }
      let(:sas_e2) { [Psc::ScheduledActivity.new(:activity_id => 'bar')] }

      before do
        sync.resolve_psc_participants

        e1.stub!(:scheduled_activities => sas_e1)
        e2.stub!(:scheduled_activities => sas_e2)
      end

      it 'returns event activity IDs grouped by PSC participant' do
        Set.new(sas).should == Set.new([
          PscSync::SAGroup.new(pscp_e1, e1, sas_e1),
          PscSync::SAGroup.new(pscp_e2, e2, sas_e2)
        ])
      end
    end

    describe '#run' do
      describe 'without a CAS URL set' do
        before do
          sync.stub!(:aker_configuration => Aker::Configuration.new)
        end

        it 'logs a warning' do
          sync.run

          log.should =~ /CAS URL not configured/i
        end

        it 'returns false' do
          sync.run.should be_false
        end
      end
    end

    describe '#grouped_instrument_sas' do
      let(:sas) { sync.grouped_instrument_sas }
      let(:pscp_i) { sync.psc_participants[instrument.participant.id] }
      let(:sas_i) { [Psc::ScheduledActivity.new] }

      before do
        sync.resolve_psc_participants

        instrument.stub!(:scheduled_activities => sas_i)
      end

      it 'returns instrument activities grouped by PSC participant' do
        Set.new(sas).should == Set.new([
          PscSync::SAGroup.new(pscp_i, instrument, sas_i)
        ])
      end
    end

    describe '#prioritize' do
      let(:pscp1) { stub }
      let(:sa1) { Psc::ScheduledActivity.new(:activity_id => 'foo') }
      let(:sa2) { Psc::ScheduledActivity.new(:activity_id => 'bar') }
      let(:sa3) { Psc::ScheduledActivity.new(:activity_id => 'baz') }

      let(:event) { stub }
      let(:instrument) { stub }

      let(:instrument_sa_groups) do
        [PscSync::SAGroup.new(pscp1, instrument, [sa1, sa2])]
      end

      let(:event_sa_groups) do
        [PscSync::SAGroup.new(pscp1, event, [sa2, sa3])]
      end

      let(:sas) { sync.prioritize(instrument_sa_groups, event_sa_groups) }

      it 'removes event SAs that are also instrument SAs' do
        sas.should == [
          [PscSync::SAGroup.new(pscp1, instrument, [sa1, sa2])],
          [PscSync::SAGroup.new(pscp1, event, [sa3])]
        ]
      end
    end

    describe '#update' do
      let(:pscp) { stub }
      let(:sa1) { Psc::ScheduledActivity.new(:activity_id => 'foo') }
      let(:sa2) { Psc::ScheduledActivity.new(:activity_id => 'bar') }

      let(:date) { '2012-01-01' }
      let(:occurred) { Psc::ScheduledActivity::OCCURRED }
      let(:reason) { 'A reason' }

      let(:object) do
        stub(:sa_end_date => date, :desired_sa_state => occurred, :sa_state_change_reason => reason)
      end

      let(:group) { PscSync::SAGroup.new(pscp, object, [sa1, sa2]) }

      let(:update_request) do
        { sa1.id => { 'date' => date, 'reason' => reason, 'state' => occurred },
          sa2.id => { 'date' => date, 'reason' => reason, 'state' => occurred }
        }
      end

      it 'updates SAs in groups' do
        pscp.should_receive(:update_scheduled_activity_states).with(update_request)

        sync.update([group])
      end
    end
  end

  describe PscSync::SAGroup do
    let(:group) { PscSync::SAGroup.new }
    let(:obj) { stub }

    before do
      group.object = obj
    end

    describe '#reject_unchanged' do
      let(:sa1) { Psc::ScheduledActivity.new }

      before do
        group.sas = [sa1]
      end

      describe 'for each activity' do
        describe 'if the activity state matches the desired state' do
          before do
            sa1.current_state = Psc::ScheduledActivity::OCCURRED
            obj.stub(:desired_sa_state => Psc::ScheduledActivity::OCCURRED)
          end

          it 'removes the activity from the group' do
            group.reject_unchanged

            group.sas.should_not include(sa1)
          end
        end

        describe 'if the activity state does not match the desired state' do
          before do
            sa1.current_state = Psc::ScheduledActivity::SCHEDULED
            obj.stub(:desired_sa_state => Psc::ScheduledActivity::OCCURRED)
          end

          it 'keeps the activity in the group' do
            group.reject_unchanged

            group.sas.should include(sa1)
          end
        end
      end
    end
  end
end
