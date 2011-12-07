Feature: Obtaining participant consent
  Since all participants must consent to be participants before proceeding with the study
  In order to ensure a consent is recorded
  As a user
  I want to initiate a contact for a participant to obtain consent
  
  Scenario: Initiating contact
    Given valid ncs codes
    And an authenticated user
    And a registered unconsented trying participant
    When I am on the new contact path for the participant
    Then I should see "Bessie Smith"
    And I should see "Consent required"
    When I select "In-person" from "Contact Type"
    And I fill in "Contact Date" with "01/01/2001"
    And I select "NCS Participant" from "Who was contacted"
    And I press "Submit"
    Then I should see "Contact was successfully created."
    And I should be on the select_instrument_contact_link page
    And I should see "Bessie Smith"
    # And I should see "INS_QUE_LIPregNotPreg_INT_LI_P2_V2.0"
    And I should see "Low-Intensity Interview"
    And I should see "Low-Intensity Consent"
    When I follow "Low-Intensity Consent"
    Then I should be on the new participant consent page
    When I select "Low Intensity Consent" from "Consent Type"
    And I fill in "Consent Date" with "01/01/2001"
    And I press "Submit"
    Then I should see "Participant consent was successfully created."
    And I should be on the select_instrument_contact_link page

    
  