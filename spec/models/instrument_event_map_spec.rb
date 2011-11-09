require 'spec_helper'

describe InstrumentEventMap do
  
  context "Segments from PSC" do
  
    it "returns the proper instruments for an segment" do
    
      instruments = InstrumentEventMap.instruments_for_segment("Pregnancy Visit 1")
      instruments.should include "INS_QUE_PregVisit1_INT_EHPBHI_P2_V2.0"
      instruments.should include "INS_QUE_PregVisit1_SAQ_EHPBHI_P2_V2.0"
      # Specimen collection has been removed
      # instruments.should include "INS_BIO_AdultBlood_DCI_EHPBHI_P2_V1.0"
      # instruments.should include "INS_BIO_AdultUrine_DCI_EHPBHI_P2_V1.0"
      # instruments.should include "INS_ENV_TapWaterPharmTechCollect_DCI_EHPBHI_P2_V1.0"
      # instruments.should include "INS_ENV_TapWaterPestTechCollect_DCI_EHPBHI_P2_V1.0"
      # instruments.should include "INS_ENV_VacBagDustTechCollect_DCI_EHPBHI_P2_V1.0"
      instruments.size.should == 2
    end
  
    it "handles the epoch prefix given by psc" do
      instruments = InstrumentEventMap.instruments_for_segment("HI-Intensity: Pregnancy Visit 1")
      instruments.size.should == 2
    end
  end

  context "Activities from PSC" do
    
    describe "Low Intensity Protocol" do
      it "returns the proper instrument for an activity" do
        [
          ["Pregnancy Screener Interview", "INS_QUE_PregScreen_INT_HILI_P2_V2.0"],
          ["Low-Intensity Interview", "INS_QUE_LIPregNotPreg_INT_LI_P2_V2.0"],
          ["Pregnancy Probability Group Follow-Up Interview", "INS_QUE_PPGFollUp_INT_EHPBHILI_P2_V1.2"],
          ["Pregnancy Probability Group Follow-Up SAQ", "INS_QUE_PPGFollUp_SAQ_EHPBHILI_P2_V1.1"],
          ["Low-Intensity Birth Interview", "INS_QUE_Birth_INT_LI_P2_V1.0"],
          ["Low Intensity Invitation to High-Intensity Conversion Interview", "INS_QUE_LIHIConversion_INT_HILI_P2_V1.0"]
        ].each do |activity, filename|
          InstrumentEventMap.instrument_for_activity(activity).should == filename
        end
      end
    end
    
    describe "High Intensity Protocol" do
      it "returns the proper instrument for an activity" do
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
          InstrumentEventMap.instrument_for_activity(activity).should == filename
        end
      end
    end
    
    it "handles activities without instruments" do
      InstrumentEventMap.instrument_for_activity("Pregnancy Health Care Log").should be_nil
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
  
  describe "recruitment type" do
    
    it "understands Two-Tier (HILI)" do
      NcsNavigatorCore.stub!(:recruitment_type).and_return("HILI")
      instruments = InstrumentEventMap.instruments_for_segment("Pregnancy Screener")
      instruments.should include "INS_QUE_PregScreen_INT_HILI_P2_V2.0"
    end
    
    it "understands Provider Based (PB)" do
      NcsNavigatorCore.stub!(:recruitment_type).and_return("PB")
      instruments = InstrumentEventMap.instruments_for_segment("Pregnancy Screener")
      instruments.should include "INS_QUE_PregScreen_INT_PB_P2_V2.0"
    end
    
    it "understands Enhanced Household (EH)" do
      NcsNavigatorCore.stub!(:recruitment_type).and_return("EH")
      instruments = InstrumentEventMap.instruments_for_segment("Pregnancy Screener")
      instruments.should include "INS_QUE_PregScreen_INT_EH_P2_V2.0"
    end
    
  end
  
end


