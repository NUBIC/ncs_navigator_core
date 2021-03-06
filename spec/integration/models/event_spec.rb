require 'spec_helper'
require 'logger'
require 'stringio'

require File.expand_path('../../../shared/models/event_psc_linkage', __FILE__)

describe Event do
  describe '.with_psc_data' do
    include_context 'event-PSC linkage'

    it 'loads scheduled activities for each event in a relation' do
      es = Event.where(:id => [screener, pv1_1].map(&:id)).with_psc_data(psc)

      es.length.should == 2
      es.all? { |e| e.scheduled_activities.length == 1 }.should be_true
    end
  end
end
