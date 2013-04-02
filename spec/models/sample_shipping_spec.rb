# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20130329150304
#
# Table name: sample_shippings
#
#  carrier                           :string(255)
#  contact_name                      :string(255)
#  contact_phone                     :string(30)
#  created_at                        :datetime
#  id                                :integer          not null, primary key
#  psu_code                          :integer          not null
#  sample_receipt_shipping_center_id :integer
#  sample_shipped_by_code            :integer          not null
#  shipment_coolant_code             :integer          not null
#  shipment_date                     :string(10)       not null
#  shipment_issues_other             :string(255)
#  shipment_time                     :string(5)
#  shipment_tracking_number          :string(36)       not null
#  shipper_destination_code          :integer          not null
#  shipper_id                        :string(36)       not null
#  staff_id                          :string(36)       not null
#  staff_id_track                    :string(36)       not null
#  transaction_type                  :string(36)
#  updated_at                        :datetime
#

require 'spec_helper'

describe SampleShipping do
  it "should create a new instance given valid attributes" do
    sample_shipping = Factory(:sample_shipping)
    sample_shipping.should_not be_nil
  end
  
  it { should belong_to(:sample_receipt_shipping_center) }
  
  context "as mdes record" do
    it "sets the public_id to a uuid" do
      ss = Factory(:sample_shipping)
      ss.public_id.should_not be_nil
      ss.shipment_tracking_number.should == ss.public_id
      ss.shipment_tracking_number.to_s.should == "ABCDE234325"
      ss.staff_id_track.should_not be_nil
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do
      @sample = Factory(:sample)
      ss = SampleShipping.create(:staff_id => "me", :shipper_id => "123", 
      :shipment_date => "02-21-2012", :shipment_tracking_number => "67876f5WERSF98", :staff_id_track => "me")
      ss.save!
 
      obj = SampleShipping.find(ss.id)
      obj.shipper_destination.local_code.should == -4
      obj.shipment_coolant.local_code.should == -4
      obj.sample_shipped_by.local_code.should == -4
    end
  end    
end

