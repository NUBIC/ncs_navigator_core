require 'spec_helper'

describe NoAccessNonInterviewReport do
  it "should create a new instance given valid attributes" do
    nanir = Factory(:no_access_non_interview_report)
    nanir.should_not be_nil
  end

  it { should belong_to(:psu) }
  it { should belong_to(:non_interview_report) }
  it { should belong_to(:nir_no_access) }

  context "as mdes record" do

    it "sets the public_id to a uuid" do
      nanir = Factory(:no_access_non_interview_report)
      nanir.public_id.should_not be_nil
      nanir.nir_no_access_id.should == nanir.public_id
      nanir.nir_no_access_id.length.should == 36
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do
      create_missing_in_error_ncs_codes(NoAccessNonInterviewReport)

      nanir = NoAccessNonInterviewReport.new
      nanir.psu = Factory(:ncs_code)
      nanir.save!

      obj = NoAccessNonInterviewReport.first
      obj.nir_no_access.local_code.should == -4

    end
  end
end
