Feature: Editing a dwelling unit
  The dwelling unit record should be updateable
  In order to edit a dwelling unit
  As a user
  I want to be able to select and edit a dwelling unit record
  
  Scenario: Editing a new dwelling unit
    Given valid ncs codes
    And an authenticated user
    And a dwelling_unit exists
    Then a dwelling_unit should exist
    When I am on the dwelling units page
    Then I should see "Dwelling Units"
    And I should see "Edit"
    When I follow "Edit" 
    Then I should be on the edit dwelling unit page
    And I should see "Edit Dwelling Unit"
    When I fill in "Comment" with "A new comment"
    And I press "Submit"
    Then I should see "Dwelling was successfully updated."
    And I should be on the dwelling units page