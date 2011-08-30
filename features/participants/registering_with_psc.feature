Feature: Registering a participant with Patient Study Calendar (PSC)
  The schedule for a participant will be determined by PSC
  In order for a participant to be known to PSC
  As a user
  I want to register that participant with the Patient Study Calendar

  Scenario: Registering a new participant with PSC
    Given a pregnant participant on the ppg1 page
    Then I should see "Not yet registered with PSC"
    When I press "Register with PSC"
    # Then I should see "Click here to view schedule in PSC"
