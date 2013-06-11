Feature: Accessing the application
  The application will initially show the upcoming activities
  In order to have a person easily work with those records
  As a user
  I want to view them when I access the application

  Scenario: Welcome index without any upcoming activities
    Given an authenticated user
    When I go to the welcome index page
    Then I should see "NCS Navigator"
    And I should see "No Scheduled Events"

  @javascript
  Scenario: Welcome index and the actions tab
    Given an authenticated user
    When I go to the welcome index page
    Then I should see "NCS Navigator"
    When I follow "Actions"
    Then I should see "Searching"
    And I should see "Participants"
    And I should not see "Upcoming Activities"
    And I should see "Pending Events"
    And I should see "Reports"
    And I should see "Case Status Report"
    And I should see "Upcoming Birth Report"
    # --- Consented Participants report is being reworked
    # And I should see "Consented Participants"


@javascript
  Scenario: Welcome index and the actions tab for an administrator
    Given an authenticated admin user
    When I go to the welcome index page
    Then I should see "NCS Navigator"
    When I follow "Actions"
    Then I should see "Searching"
    And I should see "Activities"
    And I should see "Upcoming Activities"
    And I should see "Overdue Activities"
