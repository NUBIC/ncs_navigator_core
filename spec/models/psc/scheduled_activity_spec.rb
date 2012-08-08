require 'spec_helper'

require File.expand_path('../scheduled_activity_contexts', __FILE__)

module Psc
  ##
  # These tests rely quite heavily on values present in the test fixtures.  It
  # is RECOMMENDED that you keep scheduled_activity_contexts open in a split
  # pane while reading these examples.
  describe ScheduledActivity do
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
      it_maps 'current_state.date' => 'activity_date'
      it_maps 'current_state.name' => 'current_state'
      it_maps 'ideal_date' => 'ideal_date'
      it_maps 'labels' => 'labels'
      it_maps 'study_segment' => 'study_segment'

      it 'handles empty hashes' do
        ScheduledActivity.from_schedule({}).should be_instance_of(ScheduledActivity)
      end
    end

    shared_examples_for 'a label reader' do
      def self.it_reads_label(prefix, expected)
        describe "#{prefix}_label" do
          it "returns the first label with prefix #{prefix}:" do
            sa.send("#{prefix}_label").should == expected
          end

          it 'returns nil if there is no matching label' do
            empty_sa.send("#{prefix}_label").should be_nil
          end
        end
      end

      it_reads_label 'collection',        'collection:biological'
      it_reads_label 'event',             'event:birth'
      it_reads_label 'instrument',        'instrument:ins_que_birth_int_ehpbhi_p2_v2.0_baby_name'
      it_reads_label 'order',             'order:01_02'
      it_reads_label 'participant_type',  'participant_type:child'
      it_reads_label 'references',        'references:ins_que_birth_int_ehpbhi_p2_v2.0'
    end

    shared_examples_for 'an activity state reader' do
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

    describe 'with a report row' do
      include_context 'from report'

      it_should_behave_like 'a label reader'
      it_should_behave_like 'an activity state reader'
    end

    describe 'with a schedule row' do
      include_context 'from schedule'

      it_should_behave_like 'a label reader'
      it_should_behave_like 'an activity state reader'
    end
  end
end
