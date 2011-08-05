# == Schema Information
# Schema version: 20110805151543
#
# Table name: instruments
#
#  id                       :integer         not null, primary key
#  psu_code                 :integer         not null
#  instrument_id            :binary          not null
#  event_id                 :integer
#  instrument_type_code     :integer         not null
#  instrument_type_other    :string(255)
#  instrument_version       :string(36)      not null
#  instrument_repeat_key    :integer
#  instrument_start_date    :date
#  instrument_start_time    :string(255)
#  instrument_end_date      :date
#  instrument_end_time      :string(255)
#  instrument_breakoff_code :integer         not null
#  instrument_status_code   :integer         not null
#  instrument_mode_code     :integer         not null
#  instrument_mode_other    :string(255)
#  instrument_method_code   :integer         not null
#  supervisor_review_code   :integer         not null
#  data_problem_code        :integer         not null
#  instrument_comment       :text
#  transaction_type         :string(255)
#  created_at               :datetime
#  updated_at               :datetime
#

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
    
    it "sets the public_id to a uuid" do
      ins = Factory(:instrument)
      ins.public_id.should_not be_nil
      ins.instrument_id.should == ins.public_id
      ins.instrument_id.length.should == 36
    end
    
    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do
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
