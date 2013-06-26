require 'spec_helper'

feature 'Restarting Screener for Ineligible', :clean_with_truncation, :js do

  before do
    ResponseSet.stub(:where).and_return([rs])
    PatientStudyCalendar.any_instance.stub(:scheduled_activities).and_return([scheduled_activity])
    PatientStudyCalendar.any_instance.stub(:update_activity_state).and_return(true)
    NcsNavigator::Authorization::Core::Authority.stub_chain(:new, :find_users).and_return(false)
    capybara_login('admin_user')
  end

  let!(:person) {Factory(:person)}
  let!(:inst) {Factory(:instrument, person: person)}
  let!(:event) {Factory(:event)}
  let!(:contact) {Factory(:contact)}
  let!(:contact_link) {Factory(:contact_link, contact: contact, event: event, instrument: inst)}
  let!(:rs) {Factory(:response_set, instrument: inst, person: person)}
  let(:scheduled_activity) { Factory.build(:scheduled_activity, activity_name: 'PBS Eligibility Screener Interview') }

  context 'when there is no participant' do
    it 'should show both links for Screener' do
      visit edit_instrument_path(inst.id)
      find_link('Edit Instrument Responses').visible?.should be_true
      find_link('Recreate Participant and Restart Screener').visible?.should be_true
    end

    it 'should redirect to new person contact path for person' do
      visit edit_instrument_path(inst.id)
      click_link('Recreate Participant and Restart Screener')
      page.driver.browser.switch_to.alert.accept
      page.should have_content('New Contact')
    end
  end

  context 'when there is a participant' do
    it 'should show edit responses link only' do
      person.participant = Factory(:participant)
      person.save!
      visit edit_instrument_path(inst.id)
      find_link('Edit Instrument Responses').visible?.should be_true
      page.has_link?('Recreate Participant and Restart Screener').should be_false
    end
  end

end