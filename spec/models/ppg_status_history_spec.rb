require 'spec_helper'

describe PpgStatusHistory do
  it "should create a new instance given valid attributes" do
    ppg = Factory(:ppg_status_history)
    ppg.should_not be_nil
  end
  
  it { should belong_to(:psu) }
  it { should belong_to(:participant) }
  it { should belong_to(:ppg_status) }
  it { should belong_to(:ppg_info_source) }
  it { should belong_to(:ppg_info_mode) }
  
end
