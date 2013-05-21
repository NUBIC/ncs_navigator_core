require 'spec_helper'

require File.expand_path('../scheduled_activity_contexts', __FILE__)

module Psc
  ##
  # These tests rely quite heavily on values present in the test fixtures.  It
  # is RECOMMENDED that you keep scheduled_activity_contexts open in a split
  # pane while reading these examples.
  describe ScheduledActivity do
    IE = Psc::ImpliedEntities

    let(:empty_sa) { ScheduledActivity.new }

    def self.it_maps(mapping)
      from, to = mapping.to_a.first

      it "maps #{from} to #{to}" do
        source = from.split('.').inject(row) { |r, a| r[a] }
        target = sa.send(to)

        target.should == source
      end
    end

    describe '.from_report' do
      include_context 'from report'

      it_maps 'activity_name' => 'activity_name'
      it_maps 'activity_status' => 'current_state'
      it_maps 'activity_type' => 'activity_type'
      it_maps 'grid_id' => 'activity_id'
      it_maps 'ideal_date' => 'ideal_date'
      it_maps 'labels' => 'labels'
      it_maps 'responsible_user' => 'responsible_user'
      it_maps 'scheduled_date' => 'activity_date'
      it_maps 'subject.person_id' => 'person_id'

      it 'handles empty hashes' do
        ScheduledActivity.from_report({}).should be_instance_of(ScheduledActivity)
      end
    end

    describe '.from_schedule' do
      include_context 'from schedule'

      it_maps 'activity.name' => 'activity_name'
      it_maps 'activity.type' => 'activity_type'
      it_maps 'assignment.id' => 'person_id'
      it_maps 'assignment.subject_coordinator.username' => 'responsible_user'
      it_maps 'current_state.date' => 'activity_date'
      it_maps 'current_state.name' => 'current_state'
      it_maps 'current_state.time' => 'activity_time'
      it_maps 'ideal_date' => 'ideal_date'
      it_maps 'labels' => 'labels'
      it_maps 'study_segment' => 'study_segment'

      it 'handles empty hashes' do
        ScheduledActivity.from_schedule({}).should be_instance_of(ScheduledActivity)
      end

      it 'handles empty times' do
        sa_without_time.activity_time.should be_nil
      end
    end

    shared_examples_for 'a label reader' do
      def self.it_reads_label(prefix, version, expected)
        describe "#{prefix}_label" do
          it "returns the label with prefix #{prefix} for MDES version #{version}" do
            sa.send("#{prefix}_label", version).should ==
              ActivityLabel.from_string(expected)
          end

          it 'returns nil if there is no matching label' do
            empty_sa.send("#{prefix}_label", version).should be_nil
          end
        end
      end

      it_reads_label 'collection',        '2.0', 'collection:biological'
      it_reads_label 'event',             '2.0', 'event:birth'
      it_reads_label 'instrument',        '2.0', 'instrument:2.0:ins_que_birth_int_ehpbhi_p2_v2.0_baby_name'
      it_reads_label 'order',             '2.0', 'order:01_02'
      it_reads_label 'participant_type',  '2.0', 'participant_type:child'
      it_reads_label 'references',        '2.0', 'references:2.0:ins_que_birth_int_ehpbhi_p2_v2.0'

      it_reads_label 'collection',        '3.0', 'collection:biological'
      it_reads_label 'event',             '3.0', 'event:birth'
      it_reads_label 'instrument',        '3.0', 'instrument:3.0:ins_que_birth_int_ehpbhi_p2_v3.0_baby_name'
      it_reads_label 'order',             '3.0', 'order:01_02'
      it_reads_label 'participant_type',  '3.0', 'participant_type:child'
      it_reads_label 'references',        '3.0', 'references:3.0:ins_que_birth_int_ehpbhi_p2_v3.0'

      describe '#specimen_collection?' do
        it 'returns true for activities with a collection label' do
          sa.should be_specimen_collection
        end

        it 'returns false for activities without a collection label' do
          empty_sa.should_not be_specimen_collection
        end
      end
    end

    shared_examples_for 'an activity state reader' do
      describe '#open?' do
        it 'returns true for scheduled activities' do
          sa.should be_open
        end

        it 'returns true for conditional activities' do
          sa.current_state = ScheduledActivity::CONDITIONAL

          sa.should be_open
        end

        it 'returns false if the state is blank' do
          sa.current_state = nil

          sa.should_not be_open
        end

        it 'returns false for canceled activities' do
          sa.current_state = ScheduledActivity::CANCELED

          sa.should_not be_open
        end

        it 'returns false for missed activities' do
          sa.current_state = ScheduledActivity::MISSED

          sa.should_not be_open
        end

        it 'returns false for occurred activities' do
          sa.current_state = ScheduledActivity::OCCURRED

          sa.should_not be_open
        end

        it 'returns false for activities marked N/A' do
          sa.current_state = ScheduledActivity::NA

          sa.should_not be_open
        end
      end

      describe '#closed?' do
        it 'returns !#open?' do
          sa.stub!(:open? => false)

          sa.should be_closed
        end

        it 'returns false if the state is blank' do
          sa.current_state = nil

          sa.should_not be_closed
        end
      end

      describe '#scheduled?' do
        it 'returns true for scheduled activities' do
          sa.should be_scheduled
        end

        it 'returns false for canceled activities' do
          canceled_sa.should_not be_scheduled
        end

        it 'returns false if there is no activity state' do
          empty_sa.should_not be_scheduled
        end
      end

      describe '#canceled?' do
        it 'returns true for canceled activities' do
          canceled_sa.should be_canceled
        end

        it 'returns false for scheduled activities' do
          sa.should_not be_canceled
        end

        it 'returns false if there is no activity state' do
          empty_sa.should_not be_canceled
        end
      end
    end

    shared_examples_for 'an entity deriver' do |mdes_version|
      it 'derives a person' do
        sa.derive_implied_entities(mdes_version)

        sa.person.should == IE::Person.new(sa.person_id)
      end

      it 'derives a contact' do
        sa.derive_implied_entities(mdes_version)

        sa.contact.should == IE::Contact.new(sa.activity_date, sa.person)
      end

      it 'derives an event' do
        sa.derive_implied_entities(mdes_version)

        sa.event.should == IE::Event.new(sa.event_label(mdes_version),
                                         sa.ideal_date,
                                         sa.contact,
                                         sa.person)
      end

      describe 'if the activity does not have a references label' do
        before do
          sa.labels = "event:foo instrument:#{mdes_version}:baz order:01_01"

          sa.derive_implied_entities(mdes_version)
        end

        it 'derives an instrument' do
          sa.instrument.should == IE::Instrument.new(sa.survey,
                                                     sa.referenced_survey,
                                                     sa.activity_name,
                                                     sa.event,
                                                     sa.person,
                                                     sa.order_label(mdes_version))
        end
      end

      describe 'if the activity does not have an event label' do
        before do
          sa.labels = "instrument:#{mdes_version}:foo"

          sa.derive_implied_entities(mdes_version)
        end

        it 'does not derive an instrument' do
          sa.instrument.should be_nil
        end
      end

      describe 'if the activity has a references label' do
        before do
          sa.labels = "event:foo references:#{mdes_version}:bar instrument:#{mdes_version}:baz"

          sa.derive_implied_entities(mdes_version)
        end

        it 'does not derive an instrument' do
          sa.instrument.should be_nil
        end
      end

      it 'derives a survey' do
        sa.derive_implied_entities(mdes_version)

        sa.survey.should == IE::Survey.new(sa.instrument_label(mdes_version), sa.participant_type_label(mdes_version), sa.order_label(mdes_version))
      end

      it 'derives a referenced survey' do
        sa.derive_implied_entities(mdes_version)

        sa.referenced_survey.should == IE::SurveyReference.new(sa.references_label(mdes_version))
      end

      it 'derives a contact link' do
        sa.derive_implied_entities(mdes_version)

        sa.contact_link.should == IE::ContactLink.new(sa.person,
                                                      sa.contact,
                                                      sa.event,
                                                      sa.instrument)
      end
    end

    describe 'with a report row' do
      include_context 'from report'

      it_should_behave_like 'a label reader'
      it_should_behave_like 'an activity state reader'
      it_should_behave_like 'an entity deriver', '2.0'
      it_should_behave_like 'an entity deriver', '3.0'
    end

    describe 'with a schedule row' do
      include_context 'from schedule'

      it_should_behave_like 'a label reader'
      it_should_behave_like 'an activity state reader'
      it_should_behave_like 'an entity deriver', '2.0'
      it_should_behave_like 'an entity deriver', '3.0'
    end

    let(:sa) { ScheduledActivity.new }

    describe '.new' do
      it 'accepts keyword arguments' do
        sa = ScheduledActivity.new(:activity_id => 'foo')

        sa.activity_id.should == 'foo'
      end
    end

    describe '#name' do
      it 'returns #activity_name' do
        sa.activity_name = 'foo'

        sa.name.should == 'foo'
      end
    end

    describe '#id' do
      it 'returns #activity_id' do
        sa.activity_id = 'foo'

        sa.id.should == 'foo'
      end
    end
  end
end
