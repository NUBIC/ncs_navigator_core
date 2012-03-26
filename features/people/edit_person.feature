Feature: Editing a person
  The person record should be updateable
  In order to edit a person
  As a user
  I want to be able to select and edit a person record

  Scenario: Editing a new  person
    Given valid ncs codes
    And an authenticated user
    And a person exists
    Then a person should exist
    When I am on the people page
    Then I should see "People"
    And I should see "Edit"
    When I follow "Edit"
    Then I should be on the edit person page
    And I should see "Edit Person"
    When I fill in "Comment" with "A new comment"
    And I press "Submit"
    Then I should see "Person was successfully updated."
    And I should be on the people page

  # Scenario: Editing a person without entering required attributes
  #   Given valid ncs codes
  #   And an authenticated user
  #   And a person exists
  #   Then a person should exist
  #   When I am on the edit person page
  #   And I should see "Edit Person"
  #   When I fill in "First Name" with ""
  #   And I press "Submit"
  #   Then I should see "1 error prohibited this Person from being saved"
  #   And I should see "First name can't be blank"
