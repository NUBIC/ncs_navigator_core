Feature: Accessing the specimen_pickup page
  @javascript
  Scenario: Accessing a specimen pickup page of the application
    Given valid ncs codes
    And an authenticated user
    When I go to the new specimen pickup form page
    Then I should see "Specimen Id:"
    And I should see "Specimen Pickup Date and Time:"
    And I should see "Specimen Pickup Comment Code:"
    And I should see "Specimen Pickup Comment:"
    And I should see "Specimen Pickup Comment:"

  @javascript
  Scenario: Entering valid specimen pickup form params
    Given valid ncs codes
    And an authenticated user
    When I go to the new specimen pickup form page
    And I fill in "Specimen Pickup Date and Time:" with "2012-02-23 14:45:44"
    And I fill in "Specimen Id:" with "ABC1234DE"
    And I fill in "Specimen Pickup Comment:" with "my own comment"
    And I fill in "Specimen Transport Temperature:" with "10"
    And I select "Picked Up OK" from "Specimen Pickup Comment Code:"
    And I press "Create Form"
    Then I should be on the new specimen pickup form page for that entry
    And I should see "Specimen Form was successfully created."

  @javascript
  Scenario: Entering invalid specimen pickup form params
    Given valid ncs codes
    And an authenticated user
    When I go to the new specimen pickup form page
    And I fill in "Specimen Id:" with "ABC1234DE"
    And I fill in "Specimen Pickup Comment:" with "my own comment"
    And I fill in "Specimen Transport Temperature:" with "10"
    And I select "Picked Up OK" from "Specimen Pickup Comment Code:"
    And I press "Create Form"
    Then I should be on the specimen pickup form page
