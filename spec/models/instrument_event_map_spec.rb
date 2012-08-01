# -*- coding: utf-8 -*-


require 'spec_helper'

describe InstrumentEventMap do


  it "knows all events" do
    events = InstrumentEventMap.events
    events.size.should == 17

    [ "Household Enumeration",
      # "Provider-Based Recruitment",
      "Low Intensity Data Collection",
      "Low to High Conversion",
      "Pregnancy Screener",
      "Pregnancy Probability",
      "Pre-Pregnancy",
      "Father",
      "Pregnancy Visit 1",
      "Pregnancy Visit 2",
      "Birth",
      "3M",
      "6M",
      "9M",
      "12M",
      "18M",
      "24M",
      "Validation Event"].each do |e|
      events.should include e
    end
  end

  context "finding the instrument type" do

    before(:each) do
      @psi = NcsCode.for_list_name_and_local_code('INSTRUMENT_TYPE_CL1', 5)
    end

    # INS_QUE_PregScreen_INT_HILI_P2_V2.0 2
    it "knows the instrument type for a survey" do
      InstrumentEventMap.instrument_type("INS_QUE_PregScreen_INT_HILI_P2_V2.0").should == @psi
    end

    it "knows the instrument type for a survey in parts" do
      InstrumentEventMap.instrument_type("INS_QUE_PregScreen_INT_HILI_P2_V2.0_PART_ONE").should == @psi
    end

    it "knows the instrument_type for an updated survey" do
      InstrumentEventMap.instrument_type("INS_QUE_PregScreen_INT_HILI_P2_V2.0 2").should == @psi
    end
  end

end
