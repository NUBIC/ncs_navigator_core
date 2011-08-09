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

Given /^the following pregnant participants:$/ do |table|
  table.hashes.each do |hash|
    status = Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 1: Pregnant and Eligible", :local_code => 1)
    participant = Factory(:participant, :person => Factory(:person, hash))
    Factory(:ppg_status_history, :participant => participant, :ppg_status => status)
  end
end

Given /^the following (.+) records:$/ do |factory, table|
  table.hashes.each do |hash|
    Factory(factory.to_sym, hash)
  end
end


