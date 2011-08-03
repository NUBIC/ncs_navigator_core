require 'spec_helper'

describe PregnancyVisit1 do
  it "should create a new instance given valid attributes" do
    create_missing_in_error_ncs_codes(PregnancyVisit1)
    pv1 = Factory(:pregnancy_visit_1)
    pv1.should_not be_nil
  end
  
  it { should belong_to(:participant) }
  it { should belong_to(:psu) }
  it { should belong_to(:instrument) }
  it { should belong_to(:event) }
  it { should belong_to(:dwelling_unit) }
    
  context "as mdes record" do
    
    it "sets the public_id to a uuid" do
      create_missing_in_error_ncs_codes(PregnancyVisit1)
      pv1 = Factory(:pregnancy_visit_1)
      pv1.public_id.should_not be_nil
      pv1.pv1_id.should == pv1.public_id
      pv1.pv1_id.length.should == 36
    end
    
    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do
      create_missing_in_error_ncs_codes(PregnancyVisit1)
      
      pv1 = PregnancyVisit1.new
      pv1.psu = Factory(:ncs_code)
      pv1.dwelling_unit = Factory(:dwelling_unit)
      pv1.participant = Factory(:participant)
      pv1.event = Factory(:event)
      pv1.instrument = Factory(:instrument)
      pv1.save!
    
      obj = PregnancyVisit1.first
      obj.recruit_type.local_code.should == -4
      obj.pregnant.local_code.should == -4
      obj.diabetes_1.local_code.should == -4
      obj.asthma.local_code.should == -4
      obj.insure.local_code.should == -4
      obj.water.local_code.should == -4
    end
  end
  
end
