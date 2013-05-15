require 'spec_helper'

# The values in this shared context reflect values in the
# psc/schedules_with_labels fixture.  Please read that fixture for more
# information.
shared_context 'event-PSC linkage' do
  let(:user) { mock(:username => 'dude', :cas_proxy_ticket => 'PT-cas-ticket') }
  let(:psc) { PatientStudyCalendar.new(user, Logger.new(nil)) }

  let(:event) do
    # type code 29 is Pregnancy Screener
    Factory(:event, :psc_ideal_date => '2011-08-29', :event_type_code => 29)
  end

  around do |example|
    VCR.use_cassette('psc/schedules_with_labels') { example.call }
  end

  before do
    # These are needed for participant -> PSC subject correspondence.
    pe = Factory(:person, :person_id => 'test')
    pa = Factory(:participant)

    Factory(:participant_person_link, :participant => pa, :person => pe, :relationship_code => 1)
    event.participant = pa
    event.save!
  end
end
