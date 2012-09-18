# -*- coding: utf-8 -*-


Given /^the survey has been completed$/ do
  steps %Q{
    When I go to the welcome summary page
    When I follow "PPG Group 1: Pregnant and Eligible"
    When I follow "Initiate Contact"
    When I select "In person" from "Contact Type"
    And I press "Submit"
    Then I should be on the edit_person_contact page
    And I should see "Bessie Smith"
    When I follow "INS_QUE_PregVisit1_INT_EHPBHI_P2_V2.0"
    Then I should see "PREGNANCY CARE LOG INTRODUCTION"
    When I press "PREGNANCY CARE LOG INTRODUCTION"
    Then I should see "Click here to finish"
    When I press "Click here to finish"
  }
end

Given /^a pregnancy visit 1 survey exists$/ do
  f = "#{Rails.root}/spec/fixtures/surveys/INS_QUE_PregVisit1_INT_EHPBHI_P2_V20.rb"
  Surveyor::Parser.parse File.read(f)
end

Given /^a contact record without an associated participant visit record$/ do
  participant = Factory(:participant)
  person = Factory(:person)
  participant.person = person
  participant.save!

  event = Factory(:event, :participant => participant)

  contact = Factory(:contact)
  contact_link = Factory(:contact_link, :contact => contact, :person => person, :event => event)
end

Given /^a contact record with an associated participant visit record$/ do
  participant = Factory(:participant)
  person = Factory(:person)
  participant.person = person
  participant.save!

  event = Factory(:event, :participant => participant)

  contact = Factory(:contact)
  contact_link = Factory(:contact_link, :contact => contact, :person => person, :event => event)
  Factory(:participant_visit_record, :contact => contact, :participant => participant)
end


When /^I follow today's date$/ do
  steps %Q{
    When I follow "#{Date.today.strftime('%d').to_i}"
  }
end

