require 'spec_helper'

describe PpgDetail do
  
  it "should create a new instance given valid attributes" do
    ppg = Factory(:ppg_detail)
    ppg.should_not be_nil
  end
  
  it { should belong_to(:psu) }
  it { should belong_to(:participant) }
  it { should belong_to(:ppg_pid_status) }
  it { should belong_to(:ppg_first) }
  
end
