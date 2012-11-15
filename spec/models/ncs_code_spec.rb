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
      it "returns the event type code" do
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
          code = NcsCode.for_list_name_and_display_text("EVENT_TYPE_CL1", txt)
          NcsCode.find_event_by_lbl(lbl).should == code
        end
      end
    end
  end

  context "Filter text" do
    before do
      code1 = NcsCode.new(:display_text => 'Los Angeles County, CA (Wave 3)', :local_code => 1)
      code2 = NcsCode.new(:display_text => 'Harris County, TX (Wave 2)', :local_code => 2)
      code3 = NcsCode.new(:display_text => 'Cook County, IL (Wave 1)', :local_code => 3)
      @code_display_texts = [code1.display_text, code2.display_text, code3.display_text ]
    end

    describe "#filter_text" do
      it "activates psu_code filter" do
        display_text = @code_display_texts[0]
        NcsCode.filter_text(:psu_code, display_text).should ==
          NcsCode.filter_out_wave_number_from_psu(display_text)
      end
    end

    describe "#filter_out_wave_number_from_psu_code" do

      it "removes the wave part from the PSU" do
        filtered = []
        @code_display_texts.each { |display_text| filtered << NcsCode.filter_out_wave_number_from_psu(display_text) }
        filtered.should == ['Los Angeles County, CA','Harris County, TX', 'Cook County, IL']
      end

      it "does not modify a PSU that does not contain a wave number" do
        code = NcsCode.new(:display_text => 'Philadelphia County, PA', :local_code => 4)
        NcsCode.filter_out_wave_number_from_psu(code.display_text).should == 'Philadelphia County, PA'
      end

    end
  end

end

