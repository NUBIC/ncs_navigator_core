Feature: Creating a participant record
  A pregnancy screener may determine a person to be eligible to become a Participant
  In order to create a participant
  As a user
  I want to select a Person and make them a Participant

  Scenario: Creating a new participant without a reference to a person
    Given valid ncs codes
    And an authenticated user
    When I go to the new participant page
    Then I should be on the people page
    And I should see "Cannot create a Participant without a reference to a Person"
    
  Scenario: Creating a new participant from an existing person record
    Given valid ncs codes
    And an authenticated user
    And a person exists
    When I go to the new participant page for that person
    Then I should be on the new participant page
    And I should see "New Participant"
    And I select "Age-eligible woman" from "Type"
    And I select "Person/Self" from "Status Info Source"
    And I press "Submit"
    Then I should see "Participant was successfully created."
    And I should be on the participants page
    
  Scenario: Attempting to create a new participant from a person who is already a participant
    Given valid ncs codes
    And an authenticated user
    And a participant exists
    When I go to the new participant page for that participant
    Then I should be on the edit participant page
    And I should see "Edit Participant"
    And I should see "Participant already exists"
