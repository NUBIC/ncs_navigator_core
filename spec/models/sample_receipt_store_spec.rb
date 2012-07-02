require 'spec_helper'

describe SampleReceiptStore do
  it "should create a new instance given valid attributes" do
    sample_receipt_store = Factory(:sample_receipt_store)
    sample_receipt_store.should_not be_nil
  end
  
  it { should belong_to(:sample_receipt_shipping_center) }
  it { should belong_to(:environmental_equipment) }
  it { should belong_to(:psu) }  
  it { should belong_to(:sample_condition) }
  it { should belong_to(:cooler_temp_condition) }
  it { should belong_to(:storage_compartment_area) }
  it { should belong_to(:temp_event_occurred) }
  it { should belong_to(:temp_event_action) }
  
  context "as mdes record" do
    it "sets the public_id to a uuid" do
      srs = Factory(:sample_receipt_store)
      srs.public_id.should_not be_nil
      srs.sample_id.should == srs.public_id
      srs.sample_id.to_s.should == "1234567"
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do
      srs = SampleReceiptStore.create(:sample_id => "sampleId", :staff_id => "me", :placed_in_storage_datetime => "2012-01-29 22:01:30", :receipt_datetime => "2012-01-30 22:01:30")
      srs.save!
 
      obj = SampleReceiptStore.find(srs.id)
      obj.sample_condition.local_code.should == -4
      obj.cooler_temp_condition.local_code.should == -4
      obj.storage_compartment_area.local_code.should == -4
      obj.temp_event_action.local_code.should == -4
      obj.temp_event_occurred.local_code.should == -4
    end
  end  
end

