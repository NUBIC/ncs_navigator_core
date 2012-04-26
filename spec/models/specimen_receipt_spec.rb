# == Schema Information
# Schema version: 20120420163434
#
# Table name: specimen_receipts
#
#  id                                     :integer         not null, primary key
#  psu_code                               :integer         not null
#  specimen_id                            :string(36)      not null
#  specimen_processing_shipping_center_id :integer
#  staff_id                               :string(36)      not null
#  receipt_comment_code                   :integer         not null
#  receipt_comment_other                  :string(255)
#  receipt_datetime                       :datetime        not null
#  cooler_temp                            :decimal(6, 2)
#  monitor_status_code                    :integer
#  upper_trigger_code                     :integer
#  upper_trigger_level_code               :integer
#  lower_trigger_cold_code                :integer
#  lower_trigger_ambient_code             :integer
#  storage_container_id                   :string(36)      not null
#  centrifuge_comment_code                :integer
#  centrifuge_comment_other               :string(255)
#  centrifuge_starttime                   :string(5)
#  centrifuge_endtime                     :string(5)
#  centrifuge_staff_id                    :string(36)
#  specimen_equipment_id                  :integer
#  transaction_type                       :string(36)
#  created_at                             :datetime
#  updated_at                             :datetime
#

require 'spec_helper'

describe SpecimenReceipt do
  it "should create a new instance given valid attributes" do
    specimen_receipt = Factory(:specimen_receipt)
    specimen_receipt.should_not be_nil
  end
  
  it { should belong_to(:specimen_processing_shipping_center) }
  it { should belong_to(:specimen_equipment) }
  it { should belong_to(:psu) }  
  it { should belong_to(:receipt_comment) }
  it { should belong_to(:monitor_status) }
  it { should belong_to(:upper_trigger) }
  it { should belong_to(:upper_trigger_level) }
  it { should belong_to(:lower_trigger_cold) }
  it { should belong_to(:lower_trigger_ambient) }
  it { should belong_to(:centrifuge_comment) }  
  
  context "as mdes record" do
    it "sets the public_id to a uuid" do
      sr = Factory(:specimen_receipt)
      sr.public_id.should_not be_nil
      sr.specimen_id.should == sr.public_id
      sr.specimen_id.to_s.should == "10001"
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do
      create_missing_in_error_ncs_codes(SpecimenReceipt)
      sr = Factory(:specimen_receipt, :receipt_comment => nil, :monitor_status => nil, :upper_trigger => nil, :lower_trigger_cold => nil)
      obj = SpecimenReceipt.find(sr.id)
      
      obj.receipt_comment.local_code.should == -4
      obj.monitor_status.local_code.should == -4
      obj.upper_trigger.local_code.should == -4
      obj.lower_trigger_cold.local_code.should == -4
      
    end
  end  
end
