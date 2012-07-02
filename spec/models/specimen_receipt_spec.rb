# -*- coding: utf-8 -*-
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
      sr = Factory(:specimen_receipt, :receipt_comment => nil, :monitor_status => nil, :upper_trigger => nil, :lower_trigger_cold => nil)
      obj = SpecimenReceipt.find(sr.id)

      obj.receipt_comment.local_code.should == -4
      obj.monitor_status.local_code.should == -4
      obj.upper_trigger.local_code.should == -4
      obj.lower_trigger_cold.local_code.should == -4

    end
  end
end

