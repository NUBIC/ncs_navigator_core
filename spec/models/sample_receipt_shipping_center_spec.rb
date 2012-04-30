# == Schema Information
# Schema version: 20120420163434
#
# Table name: sample_receipt_shipping_centers
#
#  id                                :integer         not null, primary key
#  psu_code                          :integer         not null
#  sample_receipt_shipping_center_id :string(36)      not null
#  transaction_type                  :string(36)
#  created_at                        :datetime
#  updated_at                        :datetime
#

require 'spec_helper'

describe SampleReceiptShippingCenter do
  it "should create a new instance given valid attributes" do
    sample_receipt_shipping_center = Factory(:sample_receipt_shipping_center)
    sample_receipt_shipping_center.should_not be_nil
  end
  
  # it { should belong_to(:address) }
  it { should belong_to(:psu) } 
  
  context "as mdes record" do
    it "sets the public_id to a uuid" do
      srsc = Factory(:sample_receipt_shipping_center)
      srsc.public_id.should_not be_nil
      srsc.sample_receipt_shipping_center_id.should == srsc.sample_receipt_shipping_center_id
      srsc.sample_receipt_shipping_center_id.to_s.should == "555"
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do
      create_missing_in_error_ncs_codes(SampleReceiptShippingCenter)
      srsc = SampleReceiptShippingCenter.create(:sample_receipt_shipping_center_id => "spscId134")
      srsc.save!
 
      obj = SampleReceiptShippingCenter.find(srsc.id)
      obj.psu.local_code.should == -4      
    end
  end  
end
