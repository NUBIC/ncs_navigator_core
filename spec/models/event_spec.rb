require 'spec_helper'

describe Event do  
  
  it "should create a new instance given valid attributes" do
    e = Factory(:event)
    e.should_not be_nil
  end
  
  it { should belong_to(:psu) }
  it { should belong_to(:participant) }
  it { should belong_to(:event_type) }
  it { should belong_to(:event_disposition_category) }
  it { should belong_to(:event_breakoff) }
  it { should belong_to(:event_incentive_type) }
  
  context "as mdes record" do
    
    it "should set the public_id to a uuid" do
      e = Factory(:event)
      e.public_id.should_not be_nil
      e.event_id.should == e.public_id
      e.event_id.length.should == 36
    end
    
    it "should use the ncs_code 'Missing in Error' for all required ncs codes" do
      create_missing_in_error_ncs_codes(Event)
      
      e = Event.new
      e.psu = Factory(:ncs_code)
      e.participant = Factory(:participant)
      e.save!
    
      obj = Event.first
      obj.event_type.local_code.should == -4
      obj.event_disposition_category.local_code.should == -4
      obj.event_breakoff.local_code.should == -4
      obj.event_incentive_type.local_code.should == -4
    end
  end

end
