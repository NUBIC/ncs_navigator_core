require 'spec_helper'

describe "/people/x/edit", :clean_with_truncation, :js do
  before(:all) {@old_selector = Capybara.default_selector;Capybara.default_selector = :xpath}
  after(:all) {Capybara.default_selector = @old_selector}

  before :each do
    capybara_login('admin_user')
  end

  it "displays a computed age when an exact DOB exists" do
    visit edit_person_path(Factory(:person, :person_dob => 10.years.ago.to_date.to_s))
    find("//label[@for='person_age']").text.should == "Age (10 years from DOB)"
  end

  it "does not display a computed age when there is no exact DOB" do
    visit edit_person_path(Factory(:person, :person_dob => nil ))
    find("//label[@for='person_age']").text.should == "Age"
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
end
