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
  dt = Date.parse("2012-12-25")
  table.hashes.each do |hash|
    status = NcsCode.for_list_name_and_local_code("PPG_STATUS_CL1", 1)
    detail_status = NcsCode.for_list_name_and_local_code("PPG_STATUS_CL2", 1)

    person = Factory(:person, hash)
    participant = Factory(:participant, :high_intensity => true, :high_intensity_state => "pregnancy_one")
    participant.person = person
    participant.save!

    Factory(:ppg_detail, :participant => participant, :ppg_first => detail_status)
    Factory(:ppg_status_history, :participant => participant, :ppg_status => status)
    participant.register!
    participant.assign_to_pregnancy_probability_group!
    participant.events << Factory(:event, :participant => participant,
                        :event_start_date => dt, :event_end_date => dt,
                        :event_type => NcsCode.pregnancy_screener)
    participant.impregnate_low!
  end
end

Given /^the following registered unconsented trying participants:$/ do |table|
  dt = Date.parse("2012-12-25")
  table.hashes.each do |hash|
    status = NcsCode.for_list_name_and_local_code("PPG_STATUS_CL1", 2)

    person = Factory(:person, hash)
    participant = Factory(:participant, :high_intensity => false)
    participant.person = person
    participant.save!

    Factory(:ppg_status_history, :participant => participant, :ppg_status => status)
    participant.register!
    participant.assign_to_pregnancy_probability_group!
    participant.events << Factory(:event, :participant => participant,
                        :event_start_date => dt, :event_end_date => dt,
                        :event_type => NcsCode.pregnancy_screener)
    participant.events << Factory(:event, :participant => participant,
                        :event_start_date => dt, :event_end_date => nil,
                        :event_type => NcsCode.low_intensity_data_collection)
    # participant.follow_low_intensity!
  end
end

Given /^the following registered unconsented high intensity trying participants:$/ do |table|
  dt = Date.parse("2012-12-25")
  table.hashes.each do |hash|
    status = NcsCode.for_list_name_and_local_code("PPG_STATUS_CL1", 2)

    person = Factory(:person, hash)
    participant = Factory(:participant, :high_intensity => true)
    participant.person = person
    participant.save!

    Factory(:ppg_status_history, :participant => participant, :ppg_status => status)
    participant.register!
    participant.assign_to_pregnancy_probability_group!
    participant.enroll_in_high_intensity_arm!
    participant.non_pregnant_informed_consent!

    participant.events << Factory(:event, :participant => participant,
                        :event_start_date => dt, :event_end_date => dt,
                        :event_type => NcsCode.pregnancy_screener)
    participant.events << Factory(:event, :participant => participant,
                        :event_start_date => dt, :event_end_date => nil,
                        :event_type => NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', 32))

  end
end

Given /^the following unregistered pregnant participants:$/ do |table|
  table.hashes.each do |hash|
    status = NcsCode.for_list_name_and_local_code("PPG_STATUS_CL1", 1)

    person = Factory(:person, hash)
    participant = Factory(:participant)
    participant.person = person
    participant.save!

    Factory(:ppg_status_history, :participant => participant, :ppg_status => status)
  end
end

Given /^the following (.+) records:$/ do |factory, table|
  table.hashes.each do |hash|
    Factory(factory.to_sym, hash)
  end
end

Given /^speaks english$/ do
  @person.update_attribute(:language_code, 1)
end

Given /^is a boy$/ do
  @child_person.update_attribute(:sex_code, 1)
end
