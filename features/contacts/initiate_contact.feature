Feature: Initiating a contact
  Since all contacts either scheduled or unscheduled must be recorded in the Contact table
  In order to ensure a contact record is created
  As a user
  I want to initiate a contact for a person and an event

  Scenario: Initiating contact
    And an authenticated user
    And a registered pregnant participant
    When I go to the welcome summary page
    Then I should see "NCS Navigator"
    And I should see "1 PPG Group 1: Pregnant and Eligible"
    When I follow "PPG Group 1: Pregnant and Eligible"
    Then I should see "Pregnancy Visit 1"
    When I follow "Bessie Smith"
    Then I follow "Initiate Contact"
    Then I should be on the new_person_contact page
    And I should see "Bessie Smith"
    And I should see "Pregnancy Visit 1"
    When I select "In-person" from "Contact Method"
    And I fill in "Contact Date" with "01/01/2001"
    # And I select "Legitimate Skip" from "Interpret"
    # And I select "Person/participant home" from "Location"
    # And I select "Yes" from "Private"
    And I select "NCS Participant" from "Person Contacted"
    And I press "Submit"
    Then I should see "Contact was successfully created."
    And I should be on the select_instrument_contact_link page
    And I should see "Bessie Smith"
    # And I should see "INS_QUE_PregVisit1_INT_EHPBHI_P2_V2.0"
    And I should see "Pregnancy Visit 1 Interview"
