# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: specimen_shippings
#
#  contact_name                           :string(255)
#  contact_phone                          :string(30)
#  created_at                             :datetime
#  id                                     :integer          not null, primary key
#  psu_code                               :integer          not null
#  shipment_date                          :string(10)       not null
#  shipment_issues_code                   :integer          not null
#  shipment_issues_other                  :string(255)
#  shipment_receipt_confirmed_code        :integer          not null
#  shipment_receipt_datetime              :datetime
#  shipment_temperature_code              :integer          not null
#  shipment_tracking_number               :string(36)       not null
#  shipper_destination                    :string(3)        not null
#  shipper_id                             :string(36)       not null
#  specimen_processing_shipping_center_id :integer
#  staff_id                               :string(36)       not null
#  storage_container_id                   :string(36)       not null
#  transaction_type                       :string(36)
#  updated_at                             :datetime
#

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
      # ss.storage_container_id.should == ss.public_id
      ss.shipper_id.to_s.should == "FEDEX"
    end
  end  
end

