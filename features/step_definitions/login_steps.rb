

Given /^I log out/ do
  steps %Q{
    Given I follow "logout"
  }
end

Given /^I log in as "([^"]*)"$/ do |username|
  @current_user = Aker::User.new(username, "NCSNavigator")

  if respond_to?(:api?)
    basic_authorize username, username
  else
    steps %Q{
      Given I am on login
      And I fill in "username" with "#{username}"
      And I fill in "password" with "#{username}"
      And I press "Log in"
    }
  end
end

Given /^an authenticated user$/ do
  steps %Q{
    Given I log in as "test_user"
  }
end