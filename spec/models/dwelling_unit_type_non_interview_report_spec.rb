# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: dwelling_unit_type_non_interview_reports
#
#  created_at                   :datetime
#  id                           :integer          not null, primary key
#  nir_dutype_id                :string(36)       not null
#  nir_dwelling_unit_type_code  :integer          not null
#  nir_dwelling_unit_type_other :string(255)
#  non_interview_report_id      :integer
#  psu_code                     :integer          not null
#  transaction_type             :string(36)
#  updated_at                   :datetime
#



require 'spec_helper'

describe DwellingUnitTypeNonInterviewReport do
  it "should create a new instance given valid attributes" do
    dutnir = Factory(:dwelling_unit_type_non_interview_report)
    dutnir.should_not be_nil
  end

  it { should belong_to(:non_interview_report) }

  context "as mdes record" do

    it "sets the public_id to a uuid" do
      dutnir = Factory(:dwelling_unit_type_non_interview_report)
      dutnir.public_id.should_not be_nil
      dutnir.nir_dutype_id.should == dutnir.public_id
      dutnir.nir_dutype_id.length.should == 36
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do

      dutnir = DwellingUnitTypeNonInterviewReport.new
      dutnir.save!

      obj = DwellingUnitTypeNonInterviewReport.first
      obj.nir_dwelling_unit_type.local_code.should == -4

    end
  end
end

