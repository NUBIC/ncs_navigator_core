Feature: Editing a household unit
  The household unit record should be updateable
  In order to edit a household unit
  As a user
  I want to be able to select and edit a household unit record
  
  Scenario: Editing a new household unit
    Given valid ncs codes
    And an authenticated user
    And a household_unit exists
    Then a household_unit should exist
    When I am on the household units page
    Then I should see "Household Units"
    And I should see "Edit"
    When I follow "Edit" 
    Then I should be on the edit household unit page
    And I should see "Edit Household Unit"
    When I fill in "Comment" with "A new comment"
    And I press "Submit"
    Then I should see "Household was successfully updated."
    And I should be on the household units page
    
    # Scenario: Editing a household unit without selecting required attributes
    #   Given a household_unit exists
    #   Then a household_unit should exist
    #   When I am on the edit household unit page
    #   And I should see "Edit Household Unit"
    #   When I fill in "Comment" with "A new comment"
    #   And I select "-- Select Status --" from "Status"
    #   And I press "Submit"
    #   Then I should see "1 error prohibited this Household Unit from being saved"
    #   And I should see "Status can't be blank"
