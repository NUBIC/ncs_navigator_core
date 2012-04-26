Then /^I enter manifest parameters$/ do
  steps %Q{
    When I fill in "shipment_tracking_number" with "1234TRACK456NO"
    And I fill in "shipment_date_and_time" with "2012-02-23 14:45:44"
    And I fill in "shipment_id" with "ABC1234DE"
    And I fill in "contact_name" with "Jane Dow"
    And I fill in "contact_phone" with "555-123-5678"
    And I fill in "carrier" with "MyMail"
  }
end

Then /^I should see entered manifest parameters$/ do
  steps %Q{
    Then I should see "Tracking Number: 1234TRACK456NO"    
    And I should see "Ship Date and Time: 2012-02-23 14:45:44"
    And I should see "Shipment ID: ABC1234DE"
    And I should see "Contact Name: Jane Dow"
    And I should see "Contact Phone: 555-123-5678"
    And I should see "Carrier: MyMail"
  }
end