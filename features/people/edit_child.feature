Feature: Editing a child record
  In order to ensure correct data
  I want to update person information for the child

  Scenario: Editing a child person record
    Given an authenticated admin user
    And a participant exists with a child
    When I am on the edit child page for a participant and contact link
    Then I should see "Edit Child"
    When I fill in "First Name" with "Johnny"
    And I fill in "Last Name" with "Doe"
    And I select "Male" from "Sex"
    And I select "Household member" from "Info Source"
    And I press "Submit"
    Then I should see "Child was successfully updated."
    And I should be on the decision_page_contact_link page