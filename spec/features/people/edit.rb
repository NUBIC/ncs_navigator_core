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
end
