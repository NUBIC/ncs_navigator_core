# -*- coding: utf-8 -*-


# == Schema Information
# Schema version: 20120404205955
#
# Table name: dwelling_unit_type_non_interview_reports
#
#  id                           :integer         not null, primary key
#  psu_code                     :integer         not null
#  nir_dutype_id                :string(36)      not null
#  non_interview_report_id      :integer
#  nir_dwelling_unit_type_code  :integer         not null
#  nir_dwelling_unit_type_other :string(255)
#  transaction_type             :string(36)
#  created_at                   :datetime
#  updated_at                   :datetime
#

require 'spec_helper'

describe DwellingUnitTypeNonInterviewReport do
  it "should create a new instance given valid attributes" do
    dutnir = Factory(:dwelling_unit_type_non_interview_report)
    dutnir.should_not be_nil
  end

  it { should belong_to(:psu) }
  it { should belong_to(:non_interview_report) }
  it { should belong_to(:nir_dwelling_unit_type) }

  context "as mdes record" do

    it "sets the public_id to a uuid" do
      dutnir = Factory(:dwelling_unit_type_non_interview_report)
      dutnir.public_id.should_not be_nil
      dutnir.nir_dutype_id.should == dutnir.public_id
      dutnir.nir_dutype_id.length.should == 36
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do
      create_missing_in_error_ncs_codes(DwellingUnitTypeNonInterviewReport)

      dutnir = DwellingUnitTypeNonInterviewReport.new
      dutnir.psu = Factory(:ncs_code)
      dutnir.save!

      obj = DwellingUnitTypeNonInterviewReport.first
      obj.nir_dwelling_unit_type.local_code.should == -4

    end
  end
end