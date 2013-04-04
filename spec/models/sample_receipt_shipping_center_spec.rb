# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: sample_receipt_shipping_centers
#
#  address_id                        :integer
#  created_at                        :datetime
#  id                                :integer          not null, primary key
#  psu_code                          :integer          not null
#  sample_receipt_shipping_center_id :string(36)       not null
#  transaction_type                  :string(36)
#  updated_at                        :datetime
#

require 'spec_helper'

describe SampleReceiptShippingCenter do
  it "should create a new instance given valid attributes" do
    sample_receipt_shipping_center = Factory(:sample_receipt_shipping_center)
    sample_receipt_shipping_center.should_not be_nil
  end

  it { should belong_to(:address) }

  context "as mdes record" do
    it "has the srsc_id" do
      srsc = Factory(:sample_receipt_shipping_center)
      srsc.sample_receipt_shipping_center_id.to_s.should == "srsc_id"
    end

    it "saves an object for all required params" do
      srsc = SampleReceiptShippingCenter.create(:sample_receipt_shipping_center_id => "srscId134", :psu_code => "20000030")
      srsc.save!
      obj = SampleReceiptShippingCenter.find(srsc.id)
      obj.psu.local_code.should == 20000030
    end
  end
end

