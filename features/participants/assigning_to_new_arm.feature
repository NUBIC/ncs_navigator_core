Feature: Assigning to new arm
  A participant will be contacted from time to time to be asked to move from the low intensity arm to the high intensity arm
  In order to move a participant to a new arm
  As a user
  I want to select the user and make the assignment change

  Scenario: Assigning to high intensity arm from low
    And an authenticated user
    And a participant exists with a person
    When I go to the edit_arm_participant page
    Then I should see "Invite Fred Rogers to join High Intensity Arm"
    When I press "Switch"
    Then I should see "Switched arm but could not schedule next event"
    And I should be on the edit participant page

  Scenario: Assigning to high intensity arm from low
    And an authenticated user
    And a high intensity participant exists with a person
    When I go to the edit_arm_participant page
    Then I should see "Move Fred Rogers from High Intensity to Low Intensity"
    When I press "Switch"
    Then I should see "Switched arm but could not schedule next event"
    And I should be on the edit participant page
