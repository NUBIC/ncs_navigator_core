Feature: Creating a dwelling unit
  The dwelling unit is a specific street address within a sampling unit
  When a dwelling unit is identified
  As a user
  I want to be able to create a dwelling unit record

  Scenario: Creating a new dwelling unit
    And an authenticated user
    When I am on the dwelling units page
    Then I should see "Dwelling Units"
    And I should see "No dwelling units were found."
    And I should see "New Dwelling Unit"
    When I follow "New Dwelling Unit"
    Then I should be on the new dwelling unit page
    And I should see "New Dwelling Unit"
    When I select "Yes" from "Duplicate Address"
    And I select "Single Family Home" from "Type of Residence"
    And I fill in "Address One" with "1 State Str."
    And I fill in "Address Two" with "Apt 2B"
    And I fill in "City" with "Chicago"
    And I select "ILLINOIS" from "State"
    And I fill in "Zip" with "60611"
    And I press "Submit"
    Then I should see "Dwelling was successfully created."
    And I should be on the dwelling units page
    And I should see "1 State Str."
    And I should see "Chicago, Illinois"
    And I should see "60611"
