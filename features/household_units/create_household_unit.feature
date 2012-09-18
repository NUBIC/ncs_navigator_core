Feature: Creating a household unit
  The household enumeration may reveal people within the household that will need to be further enumerated for study participation
  In order to have a household unit with which to associate one or more persons
  As a user
  I want to be able to create a household unit record

  Scenario: Creating a new household unit
    Given an authenticated admin user
    When I am on the household units page
    Then I should see "Household Units"
    And I should see "No household units were found."
    And I should see "New Household Unit"
    When I follow "New Household Unit"
    Then I should be on the new household unit page
    And I should see "New Household Unit"
    When I select "Yes" from "Status"
    And I select "Household informant is eligible for Pregnancy Screener" from "Eligibility"
    And I select "Single-Family Home" from "Structure"
    And I press "Submit"
    Then I should see "Household was successfully created."
    And I should be on the household units page
    And I should see "Single-Family Home"

  @javascript
  Scenario: Associating a person with a household unit
    Given an authenticated admin user
    And a person exists with first_name: "Bix", last_name: "Beiderbecke"
    When I am on the household units page
    Then I should see "Household Units"
    And I should see "No household units were found."
    And I should see "New Household Unit"
    When I follow "New Household Unit"
    And I wait 1 second
    Then I should be on the new household unit page
    And I should see "New Household Unit"
    When I select "Yes" from "Status"
    And I select "Household informant is eligible for Pregnancy Screener" from "Eligibility"
    And I select "Single-Family Home" from "Structure"
    And I follow "add_household_person_links"
    And I focus on the autocomplete input element
    And I fill in "autocomplete_combobox_person" with "Bix"
    And I wait 1 second
    Then I should see "Bix Beiderbecke"
    When I click on the "Bix Beiderbecke" autocomplete option
    And I wait 1 second
    And I press "Submit"
    Then I should see "Household was successfully created."
    And I should be on the household units page
    And I should see "Single-Family Home"

    # Scenario: Creating a new household unit without selecting required attributes
    #   Given I am on the household units page
    #   Then I should see "Household Units"
    #   And I should see "No household units were found."
    #   And I should see "New Household Unit"
    #   When I follow "New Household Unit"
    #   Then I should be on the new household unit page
    #   And I should see "New Household Unit"
    #   When I press "Submit"
    #   Then I should see "3 errors prohibited this Household Unit from being saved"
    #   And I should see "Status can't be blank"
    #   And I should see "Eligibility can't be blank"
    #   And I should see "Structure can't be blank"
