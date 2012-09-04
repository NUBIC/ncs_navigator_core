Feature: Enforce roles for users
  In order to limit the access and visibility of the application that is not congruent with a user's role
  As an administer
  I want to ensure that roles are enforced

  Scenario: A user, with the appropriate role, is allowed access to a part of the application appropriate to the role
    Given an authenticated user with a role of "Specimen Processor"
    When I go to the welcome index page
    Then I should see "Samples/Specimens"


  Scenario: A user, without the appropriate role, is not allowed access to a part of the application not appropriate to their role
    Given an authenticated user with a role of "Specimen Processor"
    When I go to the welcome index page
    Then I should not see "Participants"

