Feature: Creating a household unit
  The household enumeration may reveal people within the household that will need to be further enumerated for study participation
  In order to have a household unit with which to associate one or more persons
  As a user
  I want to be able to create a household unit record
  
  Scenario: Creating a new household unit
    Given valid ncs codes
    And the following ncs_code records:
      | list_name                 | display_text             | local_code |
      | CONFIRM_TYPE_CL2          | Yes                      | 1          |
      | HOUSEHOLD_ELIGIBILITY_CL2 | Household is eligible    | 1          |
      | RESIDENCE_TYPE_CL2        | Single-Family Home       | 1          |
    When I am on the household units page
    Then I should see "Household Units"
    And I should see "No household units were found."
    And I should see "New Household Unit"
    When I follow "New Household Unit" 
    Then I should be on the new household unit page
    And I should see "New Household Unit"
    When I select "Yes" from "Status"
    And I select "Household is eligible" from "Eligibility"
    And I select "Single-Family Home" from "Structure"
    And I press "Submit"
    Then I should see "Household was successfully created."
    And I should be on the household units page
    And I should see "Single-Family Home"