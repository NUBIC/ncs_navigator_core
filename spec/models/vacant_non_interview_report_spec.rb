# -*- coding: utf-8 -*-


require 'spec_helper'

describe VacantNonInterviewReport do
  it "should create a new instance given valid attributes" do
    vnir = Factory(:vacant_non_interview_report)
    vnir.should_not be_nil
  end

  it { should belong_to(:psu) }
  it { should belong_to(:non_interview_report) }
  it { should belong_to(:nir_vacant) }

  context "as mdes record" do

    it "sets the public_id to a uuid" do
      vnir = Factory(:vacant_non_interview_report)
      vnir.public_id.should_not be_nil
      vnir.nir_vacant_id.should == vnir.public_id
      vnir.nir_vacant_id.length.should == 36
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do

      vnir = VacantNonInterviewReport.new
      vnir.save!

      obj = VacantNonInterviewReport.first
      obj.nir_vacant.local_code.should == -4

    end
  end

end

