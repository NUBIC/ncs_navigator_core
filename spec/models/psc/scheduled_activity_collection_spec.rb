require 'spec_helper'

require File.expand_path('../scheduled_activity_collection_contexts', __FILE__)

module Psc
  describe ScheduledActivityCollection do
    describe '.from_report' do
      include_context 'from report'

      it 'creates a collection from a scheduled activity report' do
        ScheduledActivityCollection.from_report(source).should be_instance_of(ScheduledActivityCollection)
      end
    end

    describe '.from_schedule' do
      it 'creates a collection from a participant schedule'
    end
  end
end
