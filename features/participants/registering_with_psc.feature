Feature: Registering a participant with Patient Study Calendar (PSC)
  The schedule for a participant will be determined by PSC
  In order for a participant to be known to PSC
  As a user
  I want to register that participant with the Patient Study Calendar

  @javascript
  Scenario: Registering a new participant with PSC
    Given a unregistered participant on the ppg1 page
    Then I should see "Not yet registered with PSC"
    When I press "Register with PSC"
    Then I should be on the ppg1 page
    And I should see "registered with PSC"

  @javascript
  Scenario: Viewing a registered participant with PSC
    Given a registered pregnant participant on the ppg1 page
    Then I should see "2011-08-29"
    And I should see "LO-Intensity: Pregnancy Screener"
