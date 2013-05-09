Feature: Viewing a participant's information


  @javascript
  Scenario: Viewing a participants Participant Schedule tab
    Given an authenticated admin user
    And a participant with scheduled activities
    When I am on the participant page
    And I follow "Participant Schedule"
    Then activities should be grouped by date then event
