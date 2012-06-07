require 'spec_helper'

describe PbsList do
  it "should create a new instance given valid attributes" do
    pbs_list = Factory(:pbs_list)
    pbs_list.should_not be_nil
  end

  it { should belong_to(:psu) }
  it { should belong_to(:provider) }
  it { should belong_to(:substitute_provider) }
  it { should belong_to(:in_out_frame) }            # MDES 3.0
  it { should belong_to(:in_sample) }               # MDES 3.0
  it { should belong_to(:in_out_psu) }              # MDES 3.0
  it { should belong_to(:cert_flag) }               # MDES 3.0
  it { should belong_to(:frame_completion_req) }
  it { should belong_to(:pr_recruitment_status) }   # MDES 3.0

  context "as mdes record" do

    it "sets the public_id to a uuid" do
      pbs_list = Factory(:pbs_list)
      pbs_list.public_id.should_not be_nil
      pbs_list.pbs_list_id.should == pbs_list.public_id
      pbs_list.pbs_list_id.length.should == 36
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do
      pbs_list = PbsList.new
      pbs_list.psu_code = 20000030
      pbs_list.save!

      obj = PbsList.first
      obj.frame_completion_req.local_code.should == -4

      # TODO: MDES 3.0 code lists
      obj.in_out_frame.should be_nil
      obj.in_sample.should be_nil
      obj.in_out_psu.should be_nil
      obj.cert_flag.should be_nil
      obj.pr_recruitment_status.should be_nil
    end
  end

end
