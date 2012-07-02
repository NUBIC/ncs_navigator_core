# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: no_access_non_interview_reports
#
#  created_at              :datetime
#  id                      :integer          not null, primary key
#  nir_no_access_code      :integer          not null
#  nir_no_access_id        :string(36)       not null
#  nir_no_access_other     :string(255)
#  non_interview_report_id :integer
#  psu_code                :integer          not null
#  transaction_type        :string(36)
#  updated_at              :datetime
#



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

      nanir = NoAccessNonInterviewReport.new
      nanir.save!

      obj = NoAccessNonInterviewReport.first
      obj.nir_no_access.local_code.should == -4

    end
  end
end

