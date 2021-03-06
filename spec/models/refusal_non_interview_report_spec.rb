# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: refusal_non_interview_reports
#
#  created_at              :datetime
#  id                      :integer          not null, primary key
#  nir_refusal_id          :string(36)       not null
#  non_interview_report_id :integer
#  psu_code                :integer          not null
#  refusal_reason_code     :integer          not null
#  refusal_reason_other    :string(255)
#  transaction_type        :string(36)
#  updated_at              :datetime
#



require 'spec_helper'

describe RefusalNonInterviewReport do
  it "should create a new instance given valid attributes" do
    rnir = Factory(:refusal_non_interview_report)
    rnir.should_not be_nil
  end

  it { should belong_to(:non_interview_report) }

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

