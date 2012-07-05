# -*- coding: utf-8 -*-


require 'spec_helper'

describe InstrumentEventMap do

  it "returns the instrument name given the instrument filename" do
    [
      ["Pregnancy Visit 1 Interview", "INS_QUE_PregVisit1_INT_EHPBHI_P2_V2.0"],
      ["Pregnancy Visit 1 SAQ", "INS_QUE_PregVisit1_SAQ_EHPBHI_P2_V2.0"],
      ["Pre-Pregnancy Interview", "INS_QUE_PrePreg_INT_EHPBHI_P2_V1.1"],
      ["Pre-Pregnancy SAQ", "INS_QUE_PrePreg_SAQ_EHPBHI_P2_V1.1"],
      ["Pregnancy Visit 2 Interview", "INS_QUE_PregVisit2_INT_EHPBHI_P2_V2.0"],
      ["Pregnancy Visit 2 SAQ", "INS_QUE_PregVisit2_SAQ_EHPBHI_P2_V2.0"],
      ["Father Interview", "INS_QUE_Father_INT_EHPBHI_P2_V1.0"],
      ["Pregnancy Probability Group Follow-Up Interview", "INS_QUE_PPGFollUp_INT_EHPBHILI_P2_V1.2"],
      ["Pregnancy Probability Group Follow-Up SAQ", "INS_QUE_PPGFollUp_SAQ_EHPBHILI_P2_V1.1"],
    ].each do |activity, filename|
      InstrumentEventMap.name_of_instrument(filename).should == activity
    end

  end

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

    it "knows the instrument_type for an updated survey" do
      InstrumentEventMap.instrument_type("INS_QUE_PregScreen_INT_HILI_P2_V2.0 2").should == @psi
    end
  end

end
