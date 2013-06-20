# -*- coding: utf-8 -*-


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

Given /^an authenticated admin user$/ do
  steps %Q{
    Given I log in as "admin_user"
  }
end

# Changing "with_specimen" value in config file. Around block ensures it is
#   returned to its original value after the scenario
Around do |scenario, block|

  config = NcsNavigatorCore.configuration
  old_with_specimens = config.with_specimens?

  begin
    block.call
  ensure
    config.suite_configuration.core["with_specimens"] = old_with_specimens
  end
end

Given /^an authenticated user with a role of "([^"]*)"$/ do |role|
  config = NcsNavigatorCore.configuration
  config.suite_configuration.core["with_specimens"] = 'true'

  auth = Aker.configuration.authorities.detect { |auth| auth.class == Aker::Authorities::Static }

  gm = Aker::GroupMembership.new(Aker::Group.new(role))

  @current_user = auth.user('test_user') do |u|
    u.portals << "NCSNavigator"
    u.group_memberships << gm
  end

  username = "test_user"

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

Given /^an authenticated user not in the NCSNavigator portal$/ do
  steps %Q{
    Given I log in as "no_portal"
  }
end

Given /^an authenticated user with no roles$/ do
  steps %Q{
    Given I log in as "no_roles"
  }
end
