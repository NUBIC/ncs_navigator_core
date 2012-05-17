# == Schema Information
# Schema version: 20120515181518
#
# Table name: sample_shippings
#
#  id                                :integer         not null, primary key
#  psu_code                          :integer         not null
#  sample_id                         :string(36)      not null
#  sample_receipt_shipping_center_id :integer
#  staff_id                          :string(36)      not null
#  shipper_id                        :string(36)      not null
#  shipper_destination_code          :integer         not null
#  shipment_date                     :string(10)      not null
#  shipment_coolant_code             :integer         not null
#  shipment_tracking_number          :string(36)      not null
#  shipment_issues_other             :string(255)
#  staff_id_track                    :string(36)
#  sample_shipped_by_code            :integer         not null
#  transaction_type                  :string(36)
#  created_at                        :datetime
#  updated_at                        :datetime
#  volume_amount                     :decimal(6, 2)
#  volume_unit                       :string(36)
#

require 'spec_helper'

describe SampleShipping do
  it "should create a new instance given valid attributes" do
    sample_shipping = Factory(:sample_shipping)
    sample_shipping.should_not be_nil
  end
  
  it { should belong_to(:sample_receipt_shipping_center) }
  it { should belong_to(:psu) }  
  it { should belong_to(:shipper_destination) }
  it { should belong_to(:shipment_coolant) }
  it { should belong_to(:sample_shipped_by) }
  
  context "as mdes record" do
    it "sets the public_id to a uuid" do
      ss = Factory(:sample_shipping)
      ss.public_id.should_not be_nil
      ss.sample_id.should == ss.public_id
      ss.sample_id.to_s.should == "SAMPLE123ID"
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do
      ss = SampleShipping.create(:sample_id => "sampleId", :staff_id => "me", :shipper_id => "123", :shipment_date => "02-21-2012", :shipment_tracking_number => "67876f5WERSF98")
      ss.save!
 
      obj = SampleShipping.find(ss.id)
      obj.psu.local_code.should == -4      
      obj.shipper_destination.local_code.should == -4
      obj.shipment_coolant.local_code.should == -4
      obj.sample_shipped_by.local_code.should == -4
    end
  end    
end
