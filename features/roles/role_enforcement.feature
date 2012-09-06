Feature: Enforce roles for users
  In order to limit the access and visibility of the application that is not congruent with a user's role
  As an administer
  I want to ensure that roles are enforced

  Scenario: A user, with the appropriate specialized role, is allowed access to a part of the application appropriate to the role
    Given the study center collects specimens
    When I log in as "specimen_processor"
    And I go to the welcome index page
    Then I should see "Samples/Specimens"
    But I should not see "Upcoming Activities"

  Scenario: A user, without the appropriate role, is not allowed access to a part of the application not appropriate to their role
    Given the study center collects specimens
    When I log in as "staff_user"
    And I go to the welcome index page
    Then I should not see "Samples/Specimens"

  Scenario: A user, without the appropriate role, types in the address to a part of the application not appropriate to their role
    Given the study center collects specimens
    When I log in as "specimen_processor"
    And I go to the people page
    Then I should not see "People"
    And I should get a forbidden response
