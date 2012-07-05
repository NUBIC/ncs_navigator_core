Feature: Accessing the specimen_pickup page
  @javascript
  Scenario: Accessing a specimen pickup page of the application
    Given an authenticated user
    And valid specimen_processing_shipping_senter
    When I go to the new specimen pickup page
    Then I should see "Specimen Id:"
    And I should see "Specimen Pickup Date and Time:"
    And I should see "Specimen Pickup Comment Code:"
    And I should see "Specimen Pickup Comment:"
    And I should see "Specimen Pickup Comment:"

  @javascript
  Scenario: Entering valid specimen pickup form params
    Given an authenticated user
    And valid specimen_processing_shipping_senter
    When I go to the new specimen pickup page
    And I fill in "Specimen Pickup Date and Time:" with "2012-02-23 14:45:44"
    And I fill in "Specimen Id:" with "ABC1234DE"
    And I fill in "Specimen Pickup Comment:" with "my own comment"
    And I fill in "Specimen Transport Temperature:" with "10"
    And I select "Picked Up OK" from "Specimen Pickup Comment Code:"
    And I press "Create Form"
    And I wait 10 second
    Then I should see "Specimen Form was successfully created."

  @javascript
  Scenario: Entering invalid specimen pickup form params
    Given an authenticated user
    And valid specimen_processing_shipping_senter
    When I go to the new specimen pickup page
    And I fill in "Specimen Id:" with "ABC1234DE"
    And I fill in "Specimen Pickup Comment:" with "my own comment"
    And I fill in "Specimen Transport Temperature:" with "10"
    And I select "Picked Up OK" from "Specimen Pickup Comment Code:"
    And I press "Create Form"
    And I wait 10 second    
    Then I should not see "Specimen Form was successfully created."
