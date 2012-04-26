# -*- coding: utf-8 -*-

require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "selectors"))

When /^I wait (\d+) second/ do |wait_seconds|
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
    status = NcsCode.where(:list_name => "PPG_STATUS_CL1").where(:local_code => 1).first

    person = Factory(:person, hash)
    participant = Factory(:participant, :high_intensity => true, :high_intensity_state => "pregnancy_one")
    participant.participant_person_links.create(:relationship_code => 1, :psu => participant.psu, :person => person)

    Factory(:ppg_status_history, :participant => participant, :ppg_status => status)
    participant.register!
    participant.assign_to_pregnancy_probability_group!
    participant.impregnate_low!
  end
end

Given /^the following registered unconsented trying participants:$/ do |table|
  table.hashes.each do |hash|
    status = NcsCode.where(:list_name => "PPG_STATUS_CL1").where(:local_code => 2).first

    person = Factory(:person, hash)
    participant = Factory(:participant, :high_intensity => false)
    participant.participant_person_links.create(:relationship_code => 1, :psu => participant.psu, :person => person)

    Factory(:ppg_status_history, :participant => participant, :ppg_status => status)
    participant.register!
    participant.assign_to_pregnancy_probability_group!
    # participant.follow_low_intensity!
  end
end

Given /^the following registered unconsented high intensity trying participants:$/ do |table|
  table.hashes.each do |hash|
    status = NcsCode.where(:list_name => "PPG_STATUS_CL1").where(:local_code => 2).first

    person = Factory(:person, hash)
    participant = Factory(:participant, :high_intensity => true)
    participant.participant_person_links.create(:relationship_code => 1, :psu => participant.psu, :person => person)

    Factory(:ppg_status_history, :participant => participant, :ppg_status => status)
    participant.register!
    participant.assign_to_pregnancy_probability_group!
    participant.enroll_in_high_intensity_arm!
    participant.non_pregnant_informed_consent!
  end
end

Given /^the following unregistered pregnant participants:$/ do |table|
  table.hashes.each do |hash|
    status = NcsCode.where(:list_name => "PPG_STATUS_CL1").where(:local_code => 1).first

    person = Factory(:person, hash)
    participant = Factory(:participant)
    participant.participant_person_links.create(:relationship_code => 1, :psu => participant.psu, :person => person)

    Factory(:ppg_status_history, :participant => participant, :ppg_status => status)
  end
end

Given /^the following (.+) records:$/ do |factory, table|
  table.hashes.each do |hash|
    Factory(factory.to_sym, hash)
  end
end