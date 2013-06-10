require 'spec_helper'

# The values in this shared context reflect values in the
# psc/schedules_with_labels fixture.  Please read that fixture for more
# information.
shared_context 'event-PSC linkage' do
  let(:user) { mock(:username => 'dude', :cas_proxy_ticket => 'PT-cas-ticket') }
  let(:logio) { StringIO.new }
  let(:log) { logio.string }
  let(:psc) { PatientStudyCalendar.new(user, Logger.new(logio)) }

  # Pregnancy Screener, Pregnancy Visit 1
  let(:screener_code) { 29 }
  let(:pv1_code) { 13 }

  let!(:screener) do
    Factory(:event, :psc_ideal_date => '2011-08-29', :event_type_code => screener_code, :participant => participant)
  end

  let!(:pv1_1) do
    Factory(:event, :psc_ideal_date => '2011-09-03', :event_type_code => pv1_code, :participant => participant)
  end

  let(:person) { Factory(:person, :person_id => 'test') }
  let(:participant) { Factory(:participant) }

  around do |example|
    VCR.use_cassette('psc/schedules_with_labels') { example.call }
  end

  # Establishes participant -> PSC subject correspondence.
  before do
    Factory(:participant_person_link,
            :participant => participant,
            :person => person,
            :relationship_code => 1)
  end
end
