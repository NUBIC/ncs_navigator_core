Feature: Accessing the samples page
  @javascript
  Scenario: Accessing a sample page of the application
    Given valid ncs codes
    And valid sample receipts
    And valid sample shippings
    And an authenticated user
    When I go to the samples page
    Then I should see "Manifest for samples"
    And I should see not shipped samples
    
  @javascript    
  Scenario: Should be action free when no selected samples
    Given valid ncs codes
    And valid sample receipts
    And valid sample shippings
    And an authenticated user
    When I go to the samples page
    Then I should see "Manifest for samples"
    And I should see not shipped samples
    And I press "Ship"
    Then I should be on the verify samples page
    And I should see not shipped samples
    And I should see "Please select sample to ship"    
    
  @javascript
  Scenario: Selecting samples to ship
    Given valid ncs codes
    And valid sample receipts
    And valid sample shippings
    And an authenticated user
    When I go to the samples page
    And I check "SAMPLE_FIXTURES-UR11"
    And I check "SAMPLE_FIXTURES-RB10"    
    And I press "Ship"
    Then I should be on the verify samples page
    And I should see selected samples
    
  @javascript
  Scenario: Generating sample manifest with proper fields
    Given valid ncs codes
    And valid sample receipts
    And valid sample shippings
    And an authenticated user
    When I go to the samples page
    And I check "SAMPLE_FIXTURES-UR11"
    And I check "SAMPLE_FIXTURES-RB10"    
    And I press "Ship"
    Then I enter manifest parameters
    And I enter sample drop_down parameters    
    And I press "Generate Manifest"
    Then I should be on the generate samples page   
    And I should see entered manifest parameters
    And I should see entered sample drop_down parameters   
    And I should see selected samples    
    
  @javascript
  Scenario: Generating sample manifest without tracking number
    Given valid ncs codes
    And valid sample receipts
    And valid sample shippings
    And an authenticated user
    When I go to the samples page
    And I check "SAMPLE_FIXTURES-UR11"
    And I check "SAMPLE_FIXTURES-RB10"    
    And I press "Ship"

    When I enter manifest parameters with error
    And I enter sample drop_down parameters
    And I press "Generate Manifest"
    Then I should be on the generate samples page
    And I should see "Shipment tracking number can't be blank"    