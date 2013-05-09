Feature: Viewing Event windows
  In order to schedule events within the event window and mark events out
  of window The window should be displayed in several areas

  Scenario: Viewing the pending events page for an event without a window
    Given an authenticated admin user
    And a pregnancy_visit_1 pending event
    When I am on the pending events page
    Then I should see "Event Window"
    And I should see "Pregnancy Visit 1"
    And I should see "N/A" as the window

  Scenario: Viewing the pending events page for an event with a window
    Given an authenticated admin user
    And a high intensity participant with a pending birth event for a child born today
    When I am on the pending events page
    Then I should see "Event Window"
    And I should see a window from today to 10 days from now
    And I should see "(closes in 10 days)"

  @javascript
  Scenario: Viewing a participants Contact History tab for an event with a window
    Given an authenticated admin user
    And a high intensity participant with a pending birth event for a child born today
    When I am on the participant page
    And I follow "Contact History"
    Then I should see a window from today to 10 days from now
    And I should see "(closes in 10 days)"
    
  @javascript
  Scenario: Viewing a participants Participant Schedule tab for an event with a window
    Given an authenticated admin user
    And a high intensity participant with a pending birth event for a child born today
    When I am on the participant page
    And I follow "Participant Schedule"
    Then I should see "Event: Birth"
    And I should see a window from today to 10 days from now
    And I should see "(closes in 10 days)"
