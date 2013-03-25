# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: ncs_codes
#
#  created_at   :datetime
#  display_text :string(255)
#  id           :integer          not null, primary key
#  list_name    :string(255)
#  local_code   :integer
#  updated_at   :datetime
#

require 'spec_helper'

describe NcsCode do
  describe '.for_attributes' do
    it 'returns NCS codes for the given attributes' do
      NcsCode.for_attributes(:perm_closure_code, :psu_code).map(&:id).sort.should ==
        NcsCode.where(:list_name => ['CONFIRM_TYPE_CL10', 'PSU_CL1']).map(&:id).sort
    end

    it 'accepts strings for attribute names' do
      NcsCode.for_attributes('perm_closure_code', 'psu_code').map(&:id).sort.should ==
        NcsCode.where(:list_name => ['CONFIRM_TYPE_CL10', 'PSU_CL1']).map(&:id).sort
    end
  end

  it "should display attributes with user friendly method names (syntactic sugar)" do
    code = NcsCode.new(:display_text => 'foo', :local_code => 5)
    code.to_s.should == "#{code.display_text}"
    code.code.should == code.local_code
  end

  it { should validate_presence_of(:list_name) }
  it { should validate_presence_of(:display_text) }
  it { should validate_presence_of(:local_code) }

  context "finding event type using psc labels" do
    describe "#find_event_by_label" do
      [
        ["household_enumeration", "Household Enumeration"],
        ["pregnancy_probability", "Pregnancy Probability"],
        ["informed_consent", "Informed Consent"],
        ["pre-pregnancy_visit", "Pre-Pregnancy Visit"],
        ["pregnancy_visit_1", "Pregnancy Visit 1"],
        ["pregnancy_visit_2", "Pregnancy Visit 2"],
        ["birth", "Birth"],
        ["father", "Father"],
        ["validation", "Validation"],
        ["provider-based_recruitment", "Provider-Based Recruitment"],
        ["3_month", "3 Month"],
        ["6_month", "6 Month"],
        ["9_month", "9 Month"],
        ["12_month", "12 Month"],
        ["pregnancy_screener", "Pregnancy Screener"],
        ["18_month", "18 Month"],
        ["24_month", "24 Month"],
        ["low_to_high_conversion", "Low to High Conversion"],
        ["low_intensity_data_collection", "Low Intensity Data Collection"],
        ["other", "Other"],
        ["missing_in_error", "Missing in Error"],
      ].each do |lbl, txt|
        it %Q{maps "#{lbl}" to the code for "#{txt}"} do
          code = NcsCode.for_list_name_and_display_text("EVENT_TYPE_CL1", txt)
          NcsCode.find_event_by_lbl(lbl).should == code
        end
      end
    end
  end

  describe '.for_list_name_and_local_code' do
    let(:actual) { NcsCode.for_list_name_and_local_code('GENDER_CL2', 2) }

    it 'gives single NcsCode instance' do
      actual.should be_a NcsCode
    end

    it 'gives an instance for the correct code value' do
      actual.local_code.should == 2
    end

    it 'gives and instance for the correct list' do
      actual.list_name.should == 'GENDER_CL2'
    end

    it 'gives nil for an unknown list' do
      NcsCode.for_list_name_and_local_code('PICKLE_VARIETY_CL3', 1).should be_nil
    end

    it 'gives nil for an unknown code' do
      NcsCode.for_list_name_and_local_code('CONFIRM_TYPE_CL10', 24).should be_nil
    end

    it 'works when the code is a string' do
      NcsCode.for_list_name_and_local_code('GENDER_CL2', '2').should be_a NcsCode
    end
  end

  describe '.for_list_name_and_display_text' do
    let(:actual) { NcsCode.for_list_name_and_display_text('GENDER_CL2', 'Female') }

    it 'gives single NcsCode instance' do
      actual.should be_a NcsCode
    end

    it 'gives an instance for the correct text' do
      actual.display_text.should == 'Female'
    end

    it 'gives and instance for the correct list' do
      actual.list_name.should == 'GENDER_CL2'
    end

    it 'gives nil for an unknown list' do
      NcsCode.for_list_name_and_display_text('PICKLE_VARIETY_CL3', 'Garlic').should be_nil
    end

    it 'gives nil for unknown text' do
      NcsCode.for_list_name_and_display_text('CONFIRM_TYPE_CL10', 'Most Assuredly').should be_nil
    end
  end

  describe '.ncs_code_lookup' do
    let(:actual) { NcsCode.ncs_code_lookup(:p_tracing_code) }

    it 'produces an array of pairs suitable for passing to a select helper' do
      NcsCode.ncs_code_lookup(:p_tracing_code).should == [
        ['Yes', 1],
        ['No', 2]
      ]
    end

    it 'omits Missing in Error by default' do
      NcsCode.ncs_code_lookup(:p_tracing_code).collect { |p| p.last }.
        should_not include(-4)
    end

    it 'will include Missing in Error by request' do
      NcsCode.ncs_code_lookup(:p_tracing_code, true).
        should include(['Missing in Error', -4])
    end
  end
end

