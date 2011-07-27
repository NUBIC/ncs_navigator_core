require 'spec_helper'

describe Instrument do
  
  it "should create a new instance given valid attributes" do
    ins = Factory(:instrument)
    ins.should_not be_nil
  end
  
  it { should belong_to(:psu) }
  it { should belong_to(:event) }
  it { should belong_to(:instrument_type) }
  it { should belong_to(:instrument_breakoff) }
  it { should belong_to(:instrument_status) }
  it { should belong_to(:instrument_mode) }
  it { should belong_to(:instrument_method) }
  it { should belong_to(:supervisor_review) }
  it { should belong_to(:data_problem) }
  
  it { should validate_presence_of(:instrument_version) }
  
  context "as mdes record" do
    
    it "should set the public_id to a uuid" do
      ins = Factory(:instrument)
      ins.public_id.should_not be_nil
      ins.instrument_id.should == ins.public_id
      ins.instrument_id.length.should == 36
    end
    
    it "should use the ncs_code 'Missing in Error' for all required ncs codes" do
      create_missing_in_error_ncs_codes(Instrument)
      
      ins = Instrument.new(:instrument_version => "0.1")
      ins.psu = Factory(:ncs_code)
      ins.event = Factory(:event)
      ins.save!
    
      obj = Instrument.first
      obj.instrument_type.local_code.should == -4
      obj.instrument_breakoff.local_code.should == -4
      obj.instrument_status.local_code.should == -4
      obj.instrument_mode.local_code.should == -4
      obj.instrument_method.local_code.should == -4
      obj.supervisor_review.local_code.should == -4
      obj.data_problem.local_code.should == -4
    end
  end
end
