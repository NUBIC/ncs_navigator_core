# -*- coding: utf-8 -*-


require 'spec_helper'

describe NcsCode do

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
end

