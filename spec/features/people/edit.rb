require 'spec_helper'

describe "/people/x/edit", :clean_with_truncation, :js do
  before(:all) {@old_selector = Capybara.default_selector;Capybara.default_selector = :xpath}
  after(:all) {Capybara.default_selector = @old_selector}

  before :each do
    capybara_login('admin_user')
  end

  context "when an exact DOB exists" do
    it "displays a computed age" do
      visit edit_person_path(Factory(:person, :person_dob => 10.years.ago.to_date.to_s))
      find("//label[@for='person_age']").text.should == "Age (10 years from DOB)"
    end

    it "displays a computed age range" do
      visit edit_person_path(Factory(:person, :person_dob => 10.years.ago.to_date.to_s))
      find("//label[@for='person_age_range_code']").text.should == "Age Range (Less than 18 years from DOB)"
    end
  end

  context "when there is no exact DOB" do
    it "does not display a computed age" do
      visit edit_person_path(Factory(:person, :person_dob => nil ))
      find("//label[@for='person_age']").text.should == "Age"
    end

    it "does not display a computed age range" do
      visit edit_person_path(Factory(:person, :person_dob => nil ))
      find("//label[@for='person_age_range_code']").text.should == "Age Range"
    end
  end

  it "allows toggling the age and age_range fields" do
    visit edit_person_path(Factory(:person))
    find_link('Enable Age and Age Range fields').visible?.should == true
    find_link('Disable Age and Age Range fields').visible?.should == false
    find("//input[@id='person_age']")['disabled'].nil?.should == false
    find("//select[@id='person_age_range_code']")['disabled'].nil?.should == false

    click_link('Enable Age and Age Range fields')
    find_link('Enable Age and Age Range fields').visible?.should == false
    find_link('Disable Age and Age Range fields').visible?.should == true
    find("//input[@id='person_age']")['disabled'].nil?.should == true
    find("//select[@id='person_age_range_code']")['disabled'].nil?.should == true

    click_link('Disable Age and Age Range fields')
    find_link('Enable Age and Age Range fields').visible?.should == true
    find_link('Disable Age and Age Range fields').visible?.should == false
    find("//input[@id='person_age']")['disabled'].nil?.should == false
    find("//select[@id='person_age_range_code']")['disabled'].nil?.should == false
  end

  describe "redirects" do
    it "redirects to the participant's relationships tab if the person was edited from the participant's relationships tab" do
      PatientStudyCalendar.any_instance.stub(:build_activity_plan).and_return(InstrumentPlan.new)

      mother = Factory(:participant_person_link,
                      :person => Factory(:person, :first_name => 'John'),
                      :participant => Factory(:participant))

      child = Factory(:participant_person_link,
                      :person => Factory(:person),
                      :participant => Factory(:participant))

      Factory(:participant_person_link,
                     :participant => child.participant,
                     :person => mother.person,
                     :relationship_code => 2) # mother

      Factory(:participant_person_link,
                     :participant => mother.participant,
                     :person => child.person,
                     :relationship_code => 8) # child


      visit(participant_path(mother.participant))
      click_link 'Relationships'
      find("//div[@class='relation'][1]").click_link 'Edit'

      current_path.should == edit_person_path(mother.person)
      fill_in "First Name", :with => "Jon"
      click_button "Submit"

      current_path.should == participant_path(mother.participant)
      mother.person.reload.first_name.should == "Jon"
      find('//div[@id="relationships_tab"]').should be_visible

      find("//div[@class='relation'][2]").click_link 'Edit'
      current_path.should == edit_person_path(child.person)
      click_button "Submit"

      current_path.should == participant_path(mother.participant)
      find('//div[@id="relationships_tab"]').should be_visible
    end

    it "redirects to the provider page if the person was edited from the provider page" do
      plink = Factory(:participant_person_link,
                      :person => Factory(:person, :first_name => 'John', :last_name => 'Doe'),
                      :participant => Factory(:participant))
      provider = Factory(:person_provider_link, :person => plink.person, :provider => Factory(:provider)).provider

      visit(provider_path(provider))
      click_link 'John Doe'

      current_path.should == edit_provider_person_path(provider,plink.person)
      click_button 'Submit'

      current_path.should == provider_path(provider)
    end
  end
end
