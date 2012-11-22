require 'spec_helper'

require File.expand_path('../scheduled_activity_collection_contexts', __FILE__)

module Psc
  ##
  # These tests rely quite heavily on values present in the test fixtures.  It
  # is RECOMMENDED that you keep scheduled_activity_collection_contexts open in
  # a split pane while reading these examples.
  describe ScheduledActivityCollection do
    describe '.from_report' do
      include_context 'collection from report'

      let(:report) { ScheduledActivityCollection.from_report(source) }

      it 'creates one ScheduledActivity per report row' do
        report.length.should == 2
      end

      it 'returns an empty collection when given nil' do
        ScheduledActivityCollection.from_report(nil).should be_instance_of(ScheduledActivityCollection)
      end
    end

    describe '.from_schedule' do
      include_context 'collection from schedule'

      let(:report) { ScheduledActivityCollection.from_schedule(source) }

      it 'creates one ScheduledActivity per activity set' do
        report.length.should == 6
      end

      it 'returns an empty collection when given nil' do
        ScheduledActivityCollection.from_schedule(nil).should be_instance_of(ScheduledActivityCollection)
      end
    end
  end
end
