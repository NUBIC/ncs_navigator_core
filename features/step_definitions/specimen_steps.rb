# -*- coding: utf-8 -*-
Given /^valid specimen receipts$/ do
  Factory(:specimen_receipt, :specimen_id => "FIXTURES-UR01", :staff_id => "me", :storage_container_id => "FIXTURES001")
  Factory(:specimen_receipt, :specimen_id => "FIXTURES-UR11", :staff_id => "me", :storage_container_id => "FIXTURES001")
  Factory(:specimen_receipt, :specimen_id => "FIXTURES-UR21", :staff_id => "me", :storage_container_id => "FIXTURES001")
  Factory(:specimen_receipt, :specimen_id => "FIXTURES-RB10", :staff_id => "me", :storage_container_id => "FIXTURES002")
  Factory(:specimen_receipt, :specimen_id => "FIXTURES-RB13", :staff_id => "me", :storage_container_id => "FIXTURES003")
  Factory(:specimen_receipt, :specimen_id => "FIXTURES-UR45", :staff_id => "me", :storage_container_id => "FIXTURES005")
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

Then /^I should see selected specimens$/ do
  steps %Q{
    Then I should see "FIXTURES001"
    And I should see "FIXTURES-UR01"
    And I should see "FIXTURES-UR11"
    And I should see "FIXTURES-UR21"
    And I should not see "FIXTURES-RB10"
    And I should not see "FIXTURES-RB13"
    And I should not see "FIXTURES-RB45"
    And I should see "Total # Containers: 1"
    And I should see "Total # Samples: 3"
  }
end

And /^I enter specimen drop_down parameters$/ do
  steps %Q{
    And I select "Cold Packs" from "temp[]"
    And I select "TWQ lab" from "dest[]"
  }
end 

And /^I should see entered specimen drop_down parameters$/ do
  steps %Q{
    And I should see "Shipping Temperature: Cold Packs"
    And I should see "Sent to Site: TWQ lab"
  }  
end 

When /^I enter manifest parameters with error$/ do
  steps %Q{
    When I fill in "shipment_date_and_time" with "2012-02-23 14:45:44"
    And I fill in "shipment_id" with "ABC1234DE"
    And I fill in "contact_name" with "Jane Dow"
    And I fill in "contact_phone" with "555-123-5678"
    And I fill in "carrier" with "MyMail"
  }
end