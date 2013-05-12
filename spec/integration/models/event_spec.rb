require 'spec_helper'
require 'logger'
require 'stringio'

describe Event do
  describe '.with_psc_data' do
    let(:user) { mock(:username => 'dude', :cas_proxy_ticket => 'PT-cas-ticket') }

    let(:e1) do
      # Type 29 designates a pregnancy screener.
      Factory(:event, :psc_ideal_date => '2011-08-29', :event_type_code => 29)
    end

    let(:psc) { PatientStudyCalendar.new(user, Logger.new(nil)) }

    around do |example|
      VCR.use_cassette('psc/schedules_with_labels') { example.call }
    end

    before do
      # These are needed for participant -> PSC subject correspondence.
      pe = Factory(:person, :person_id => 'test')
      pa = Factory(:participant)

      Factory(:participant_person_link, :participant => pa, :person => pe, :relationship_code => 1)
      e1.participant = pa
      e1.save!
    end

    it 'loads scheduled activities for each event in a relation' do
      es = Event.where(:id => e1.id).with_psc_data(psc)

      es.length.should == 1
      es.first.scheduled_activities.length.should == 1
    end
  end
end
