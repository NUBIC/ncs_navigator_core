# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: specimen_receipts
#
#  centrifuge_comment_code                :integer
#  centrifuge_comment_other               :string(255)
#  centrifuge_endtime                     :string(5)
#  centrifuge_staff_id                    :string(36)
#  centrifuge_starttime                   :string(5)
#  centrifuge_temp                        :decimal(6, 2)
#  cooler_temp                            :decimal(6, 2)
#  created_at                             :datetime
#  id                                     :integer          not null, primary key
#  lower_trigger_ambient_code             :integer
#  lower_trigger_cold_code                :integer
#  monitor_status_code                    :integer
#  psu_code                               :integer          not null
#  receipt_comment_code                   :integer          not null
#  receipt_comment_other                  :string(255)
#  receipt_datetime                       :datetime         not null
#  specimen_equipment_id                  :integer
#  specimen_id                            :integer          not null
#  specimen_processing_shipping_center_id :integer
#  specimen_storage_container_id          :integer          not null
#  staff_id                               :string(36)       not null
#  transaction_type                       :string(36)
#  updated_at                             :datetime
#  upper_trigger_code                     :integer
#  upper_trigger_level_code               :integer
#

require 'spec_helper'

describe SpecimenReceipt do
  it "should create a new instance given valid attributes" do
    specimen_receipt = Factory(:specimen_receipt)
    specimen_receipt.should_not be_nil
  end

  it { should belong_to(:specimen_processing_shipping_center) }
  it { should belong_to(:specimen_storage_container) }
  it { should belong_to(:specimen_equipment) }

  context "as mdes record" do
    it "sets the public_id to a uuid" do
      sr = Factory(:specimen_receipt)
      sr.public_id.should_not be_nil
      sr.specimen_id.should == sr.public_id
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do
      sr = Factory(:specimen_receipt, :receipt_comment => nil, :monitor_status => nil, :upper_trigger => nil, :lower_trigger_cold => nil)
      obj = SpecimenReceipt.find(sr.id)

      obj.receipt_comment.local_code.should == -4
      obj.monitor_status.local_code.should == -4
      obj.upper_trigger.local_code.should == -4
      obj.lower_trigger_cold.local_code.should == -4

    end
  end
end

