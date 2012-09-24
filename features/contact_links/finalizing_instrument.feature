Feature: Finalizing an instrument
  A contact link record needs to be created when a survey has been completed
  The Contact Link record associates a unique combination of Staff Member, Person, Event, and/or Instrument that occurs during a Contact.
  In order to ensure a contact link record is created after a survey has been completed
  As a user
  I want to complete the entry of the contact link
x
  Scenario: Finalizing an instrument
  Given a registered pregnant participant on the ppg1 page with an instrument
  When I follow "Bessie Smith"
  Then I follow "Initiate Contact"
  And I select "In-person" from "Contact Method"
  And I press "Submit"
  Then I should be on the select_instrument_contact_link page
  And I should see "Bessie Smith"
  And I should see "Pregnancy Visit 1"
  When I follow "Pregnancy Visit 1"
  And I press "Pregnancy care log introduction"
  Then I should see "Pregnancy care log introduction"
  When I press "Click here to finish"
  Then I should be on the edit_instrument_contact_link page
  And I should see "Bessie Smith has completed Instrument - INS_QUE_PregVisit1_INT_EHPBHI_P2_V2.0"
  When I select "Complete" from "Instrument Status"
  And I press "Submit"
  Then I should be on the decision_page_contact_link page
  And I should see "Administer another Instrument for this Event"
  And I should see "Create Participant Record of Visit"
  And I should see "Enter information about the Visit"
  And I should see "Complete Contact and Event Records"
  When I follow "Complete Contact and Event Records"
  Then I should be on the edit_contact_link page
  And I should see "Remember to record the Contact and Event Dispositions."
  And I should see "Bessie Smith has completed Instrument - INS_QUE_PregVisit1_INT_EHPBHI_P2_V2.0"
  When I select "Completed interview in English" from "contact_contact_disposition"
  And I select "Completed interview in English" from "event_event_disposition"
  # And I press "Should this event be closed?"
  # Then I should see "Hide End Date and Time Fields"
  # And I click "Event end date"
  # And I follow today's date
  And I press "Close"
  Then I should be on the participant page
  And I should see "Contact was successfully updated."
  And I should see "Bessie Smith"
  And I should see "High Intensity Participant :: PPG Group 1: Pregnant and Eligible "
