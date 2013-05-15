require 'spec_helper'
require 'logger'
require 'stringio'

require File.expand_path('../../../shared/models/event_psc_linkage', __FILE__)

describe Event do
  describe '.with_psc_data' do
    include_context 'event-PSC linkage'

    it 'loads scheduled activities for each event in a relation' do
      es = Event.where(:id => event.id).with_psc_data(psc)

      es.length.should == 1
      es.first.scheduled_activities.length.should == 1
    end
  end
end
