require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "selectors"))

When /^I wait (\d+) seconds$/ do |wait_seconds|
  sleep(wait_seconds.to_i)
end

When /^I click on the "(.*)" autocomplete option$/ do |link_text|
  # this should work in future versions but not currently stable
  # page.evaluate_script %Q{ $('.ui-menu-item a:contains("#{link_text}")').trigger("mouseenter").click(); }
  page.driver.browser.execute_script %Q{ $('.ui-menu-item a:contains("#{link_text}")').trigger("mouseenter").click(); }
end

When /^I focus on the autocomplete input element$/ do
  page.driver.browser.execute_script "$('.ui-autocomplete-input').focus();"
  page.driver.browser.execute_script "$('.ui-autocomplete-input').val('');"
end

Given /^the following (.+) records:$/ do |factory, table|
  table.hashes.each do |hash|
    Factory(factory.to_sym, hash)
  end
end

Given /^valid ncs codes$/ do
  Factory(:ncs_code, :list_name => "PSU_CL1", :display_text => "Cook County, IL (Wave 1)", :local_code => SystemConfiguration.psu_code)
  Factory(:ncs_code, :list_name => "CONFIRM_TYPE_CL2", :display_text => "Yes", :local_code => 1)
  Factory(:ncs_code, :list_name => "HOUSEHOLD_ELIGIBILITY_CL2", :display_text => "Household is eligible", :local_code => 1)
  Factory(:ncs_code, :list_name => "RESIDENCE_TYPE_CL2", :display_text => "Single-Family Home", :local_code => 1)
  Factory(:ncs_code, :list_name => "NAME_PREFIX_CL1", :display_text => "Mr.", :local_code => 1)
  Factory(:ncs_code, :list_name => "NAME_SUFFIX_CL1", :display_text => "Jr.", :local_code => 1)
  Factory(:ncs_code, :list_name => "GENDER_CL1", :display_text => "Male", :local_code => 1)
  Factory(:ncs_code, :list_name => "AGE_RANGE_CL1", :display_text => "18-24", :local_code => 2)
  Factory(:ncs_code, :list_name => "CONFIRM_TYPE_CL2", :display_text => "Yes", :local_code => 1)
  Factory(:ncs_code, :list_name => "ETHNICITY_CL1", :display_text => "Not Hispanic or Latino", :local_code => 2)
  Factory(:ncs_code, :list_name => "LANGUAGE_CL2", :display_text => "English", :local_code => 1)
  Factory(:ncs_code, :list_name => "MARITAL_STATUS_CL1", :display_text => "Married", :local_code => 1)
  Factory(:ncs_code, :list_name => "CONTACT_TYPE_CL1", :display_text => "In-person", :local_code => 1)
  Factory(:ncs_code, :list_name => "CONFIRM_TYPE_CL1", :display_text => "Yes", :local_code => 1)  
  Factory(:ncs_code, :list_name => "MOVING_PLAN_CL1", :display_text => "Address known", :local_code => 1)  
  Factory(:ncs_code, :list_name => "CONFIRM_TYPE_CL4", :display_text => "Yes", :local_code => 1)  
  Factory(:ncs_code, :list_name => "INFORMATION_SOURCE_CL4", :display_text => "Person/Self", :local_code => 1)
  
  create_missing_in_error_ncs_codes(Person)
  create_missing_in_error_ncs_codes(HouseholdUnit)
  create_missing_in_error_ncs_codes(DwellingUnit)
  create_missing_in_error_ncs_codes(Address)
  create_missing_in_error_ncs_codes(HouseholdPersonLink)
end


def create_missing_in_error_ncs_codes(cls)
  cls.reflect_on_all_associations.each do |association|
    if association.options[:class_name] == "NcsCode"
      list_name = association.options[:conditions].gsub("'", "").gsub("list_name = ", "")
      Factory(:ncs_code, :local_code => '-4', :display_text => 'Missing in Error', :list_name => list_name)
    end
  end
end
