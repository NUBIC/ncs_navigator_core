Feature: Creating a child person and participant record
  In order to adminster some instruments for a child participant
  I need to create a child person and particpant record
  And associate that person record with the mother participant

  Scenario: Creating a new child person record
    Given an authenticated admin user
    And a participant exists with a person
    When I am on the new child page for a participant and contact link
    Then I should see "New Child"
    When I fill in "First Name" with "John"
    And I fill in "Last Name" with "Doe"
    And I select "Male" from "Sex"
    And I select "Household member" from "Info Source"
    And I press "Submit"
    Then I should see "Child was successfully created."
    And I should be on the decision_page_contact_link page