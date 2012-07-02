# -*- coding: utf-8 -*-


require 'spec_helper'

describe RefusalNonInterviewReport do
  it "should create a new instance given valid attributes" do
    rnir = Factory(:refusal_non_interview_report)
    rnir.should_not be_nil
  end

  it { should belong_to(:psu) }
  it { should belong_to(:non_interview_report) }
  it { should belong_to(:refusal_reason) }

  context "as mdes record" do

    it "sets the public_id to a uuid" do
      rnir = Factory(:refusal_non_interview_report)
      rnir.public_id.should_not be_nil
      rnir.nir_refusal_id.should == rnir.public_id
      rnir.nir_refusal_id.length.should == 36
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do

      rnir = RefusalNonInterviewReport.new
      rnir.save!

      obj = RefusalNonInterviewReport.first
      obj.refusal_reason.local_code.should == -4

    end
  end
end

