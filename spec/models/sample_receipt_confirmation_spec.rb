# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: sample_receipt_confirmations
#
#  created_at                        :datetime
#  id                                :integer          not null, primary key
#  psu_code                          :integer          not null
#  sample_condition_code             :integer          not null
#  sample_id                         :integer          not null
#  sample_receipt_shipping_center_id :integer
#  sample_receipt_temp               :decimal(6, 2)    not null
#  sample_shipping_id                :integer          not null
#  shipment_condition_code           :integer          not null
#  shipment_damaged_reason           :string(255)
#  shipment_receipt_confirmed_code   :integer          not null
#  shipment_receipt_datetime         :datetime         not null
#  shipment_received_by              :string(255)      not null
#  shipper_id                        :string(255)      not null
#  staff_id                          :string(255)      not null
#  transaction_type                  :string(36)
#  updated_at                        :datetime
#

require 'spec_helper'

describe SampleReceiptConfirmation do
  it "should create a new instance given valid attributes" do
    sample_receipt_confirmation = Factory(:sample_receipt_confirmation)
    sample_receipt_confirmation.should_not be_nil
  end
  
  it { should belong_to(:sample_receipt_shipping_center) }
  
  context "as mdes record" do
    it "sets the public_id to a uuid" do
      src = Factory(:sample_receipt_confirmation)
      src.public_id.should_not be_nil
      src.sample_id.should == src.public_id
      src.sample.sample_id.to_s.should == "SAMPLE123ID"
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do
      @sample_shipping = Factory(:sample_shipping)
      @sample = Factory(:sample)
      src = SampleReceiptConfirmation.create(:sample_id => @sample.id, :sample_receipt_shipping_center_id => "srsc_1", 
                                            :shipper_id => @sample_shipping.shipper_id, :sample_shipping_id => @sample_shipping.id,
                                            :shipment_received_by => "Jane Dow", :sample_receipt_temp => "-2.1", :staff_id => "someidforstaff", 
                                            :shipment_receipt_datetime => Time.now)
      
      src.save!

      obj = SampleReceiptConfirmation.find(src.id)
      obj.shipment_receipt_confirmed.local_code.should == -4
      obj.shipment_condition.local_code.should == -4
      obj.sample_condition.local_code.should == -4
    end
  end
end

