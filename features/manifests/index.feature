Feature: Accessing the manifest page
  @javascript
  Scenario: Accessing a manifest page of the application
    Given valid ncs codes
    And an authenticated user
    When I go to the manifest page
    And I wait 2 second
    Then I should see "Specimens"
    And I should see "Samples"

  @javascript
  Scenario: Accessing a manifest page of the application
    Given valid ncs codes
    And an authenticated user
    When I go to the manifest page
    And I follow "Specimens"
    And I wait 2 second
    Then I should be on the specimens page

  @javascript
  Scenario: Accessing a manifest page of the application
    Given valid ncs codes
    And an authenticated user
    When I go to the manifest page
    And I follow "Samples"
    And I wait 20 second
    Then I should be on the samples page    