# -*- coding: utf-8 -*-
require 'spec_helper'

describe SpecimenShipping do
  it "should create a new instance given valid attributes" do
    specimen_shipping = Factory(:specimen_shipping)
    specimen_shipping.should_not be_nil
  end
  
  it { should belong_to(:specimen_processing_shipping_center) }
  it { should belong_to(:psu) }  
  it { should belong_to(:shipment_temperature) }
  it { should belong_to(:shipment_receipt_confirmed) }
  it { should belong_to(:shipment_issues) }
  
  context "as mdes record" do
    it "sets the public_id to a uuid" do
      ss = Factory(:specimen_shipping, :shipper_id => "FEDEX")
      ss.public_id.should_not be_nil
      ss.storage_container_id.should == ss.public_id
      ss.shipper_id.to_s.should == "FEDEX"
    end
  end  
end

