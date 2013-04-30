# -*- coding: utf-8 -*-
Given /^a high intensity participant with a pending birth event for a child born today$/ do

  child = Factory(:participant_person_link,
                  :person => Factory(:person, :person_dob => Time.zone.today.to_s(:db)),
                  :participant => Factory(:participant, :high_intensity => true))

  # needs to be Participant.last
  mother  = Factory(:participant_person_link,
                    :person => Factory(:person, :person_id => "w324-rteb-2c7z"),
                    :participant => Factory(:participant, :high_intensity => true))

  link = Factory(:participant_person_link,
                 :participant => child.participant,
                 :person => mother.person,
                 :relationship_code => 2) # mother

  link = Factory(:participant_person_link,
                 :participant => mother.participant,
                 :person => child.person,
                 :relationship_code => 8) # child

  # @todo should be :participant => child.participant
  Factory(:event, :event_type_code => Event.birth_code, :participant => mother.participant, :psc_ideal_date => "2013-05-10")
end

Then /^I should see a window from today to (\d+) days from now$/ do |end_days|
  window_start = "#{Time.zone.today.to_s(:db)}"
  window_end   = "#{(Time.zone.today + end_days.to_i.days).to_s(:db)}"
  step "I should see \"#{window_start} – #{window_end}\" as the window" #thats &ndash;
end

Then /^I should see "([^"]*)" as the window$/ do |window|
  assert page.has_css?("span.event_window", :visible => true)
  assert page.first("span.event_window", :visible => true).has_content?(window)
end
