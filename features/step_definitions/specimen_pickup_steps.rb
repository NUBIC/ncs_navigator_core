Given /^valid specimen pickup configuration params$/ do
  Factory(:specimen_pickup)
end

Given /^valid specimen shippings$/ do
  Factory(:specimen_shipping, :storage_container_id => "FIXTURES002", :staff_id => "abc1", :shipper_id => "FEDEX", :shipper_destination => "LAB", :shipment_date => "01/27/2012", :shipment_tracking_number => "001FEDEXTRACK")
  Factory(:specimen_shipping, :storage_container_id => "FIXTURES004", :staff_id => "abc2", :shipper_id => "FEDEX", :shipper_destination => "LAB", :shipment_date => "01/28/2012", :shipment_tracking_number => "002FEDEXTRACK")
  Factory(:specimen_shipping, :storage_container_id => "FIXTURES006", :staff_id => "abc3", :shipper_id => "FEDEX", :shipper_destination => "LAB", :shipment_date => "01/29/2012", :shipment_tracking_number => "003FEDEXTRACK")
  Factory(:specimen_shipping, :storage_container_id => "FIXTURES007", :staff_id => "abc1", :shipper_id => "FEDEX", :shipper_destination => "LAB", :shipment_date => "01/27/2012", :shipment_tracking_number => "001FEDEXTRACK")
  Factory(:specimen_shipping, :storage_container_id => "FIXTURES008", :staff_id => "abc2", :shipper_id => "FEDEX", :shipper_destination => "LAB", :shipment_date => "01/29/2012", :shipment_tracking_number => "003FEDEXTRACK")
  Factory(:specimen_shipping, :storage_container_id => "FIXTURES009", :staff_id => "abc3", :shipper_id => "FEDEX", :shipper_destination => "LAB", :shipment_date => "01/30/2012", :shipment_tracking_number => "004FEDEXTRACK")
end

Then /^I should see not shipped specimens$/ do
  steps %Q{
    Then I should see "FIXTURES-UR01"
    And I should see "FIXTURES-UR11"
    And I should see "FIXTURES-UR21"
    And I should see "FIXTURES-RB13"
    And I should see "FIXTURES-UR45"
    And I should not see "FIXTURES-RB10"
  }
end