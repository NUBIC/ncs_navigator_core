Feature: Assigning to new arm
  A participant will be contacted from time to time to be asked to move from the low intensity arm to the high intensity arm
  In order to move a participant to a new arm
  As a user
  I want to select the user and make the assignment change
  
  Scenario: Assigning to high intensity arm from low
    Given valid ncs codes
    And an authenticated user
    And a participant exists
    And valid ncs codes
    When I go to the edit_arm_participant page
    Then I should see "Switch from Low Intensity to High Intensity"
    When I press "Switch"
    Then I should see "Successfully added Fred Rogers to High Intensity Arm"
    And I should be on the edit participant page

  Scenario: Assigning to high intensity arm from low
    Given valid ncs codes
    And an authenticated user
    And a participant exists with high_intensity: true
    And valid ncs codes
    When I go to the edit_arm_participant page
    Then I should see "Switch from High Intensity to Low Intensity"
    When I press "Switch"
    Then I should see "Successfully added Fred Rogers to Low Intensity Arm"
    And I should be on the edit participant page