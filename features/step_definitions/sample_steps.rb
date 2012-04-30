Given /^valid sample receipts$/ do
  Factory(:sample_receipt_store, :sample_id => "SAMPLE_FIXTURES-UR01", :staff_id => "test", :placed_in_storage_datetime => "2012-01-29 22:01:30", :receipt_datetime => "2012-01-30 22:01:30")
  Factory(:sample_receipt_store, :sample_id => "SAMPLE_FIXTURES-UR11", :staff_id => "test", :placed_in_storage_datetime => "2012-01-29 22:01:30", :receipt_datetime => "2012-01-30 22:01:30")
  Factory(:sample_receipt_store, :sample_id => "SAMPLE_FIXTURES-UR21", :staff_id => "test", :placed_in_storage_datetime => "2012-01-29 22:01:30", :receipt_datetime => "2012-01-30 22:01:30")
  Factory(:sample_receipt_store, :sample_id => "SAMPLE_FIXTURES-RB10", :staff_id => "test", :placed_in_storage_datetime => "2012-01-29 22:01:30", :receipt_datetime => "2012-01-30 22:01:30")
  Factory(:sample_receipt_store, :sample_id => "SAMPLE_FIXTURES-RB13", :staff_id => "test", :placed_in_storage_datetime => "2012-01-29 22:01:30", :receipt_datetime => "2012-01-30 22:01:30")
  Factory(:sample_receipt_store, :sample_id => "SAMPLE_FIXTURES-UR45", :staff_id => "test", :placed_in_storage_datetime => "2012-01-29 22:01:30", :receipt_datetime => "2012-01-30 22:01:30")
end

Given /^valid sample shippings$/ do
  Factory(:sample_shipping, :sample_id => "SAMPLE_FIXTURES-UR21", :staff_id => "me", :shipper_id => "123", :shipment_date => "02-21-2012", :shipment_tracking_number => "67876f5WERSF98", :shipment_coolant => nil)
  Factory(:sample_shipping, :sample_id => "SAMPLE_FIXTURES-RB13", :staff_id => "me", :shipper_id => "123", :shipment_date => "02-21-2012", :shipment_tracking_number => "67876f5WERSF98", :shipment_coolant => nil)
end

Then /^I should see not shipped samples$/ do
  steps %Q{
    Then I should see "SAMPLE_FIXTURES-UR01"
    And I should see "SAMPLE_FIXTURES-UR11"
    And I should see "SAMPLE_FIXTURES-RB10"
    And I should see "SAMPLE_FIXTURES-UR45"
  }
end

Then /^I should see selected samples$/ do
  steps %Q{
    And I should see "SAMPLE_FIXTURES-UR11"
    And I should see "SAMPLE_FIXTURES-RB10"
    And I should not see "SAMPLE_FIXTURES-UR45"
    And I should not see "SAMPLE_FIXTURES-UR01"
    And I should see "Total # Containers: 2"
    And I should see "Total # Samples: 2"
  }
end

And /^I enter sample drop_down parameters$/ do
  steps %Q{
    And I select "Dry Ice" from "temp[]"
    And I select "Vacuum Bag Dust Processing Lab" from "dest[]"
  }
end

And /^I should see entered sample drop_down parameters$/ do
  steps %Q{
    And I should see "Shipping Temperature: Dry Ice"
    And I should see "Sent to Site: Vacuum Bag Dust Processing Lab"
  }
end

