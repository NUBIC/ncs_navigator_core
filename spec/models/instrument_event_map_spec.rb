require 'spec_helper'

describe InstrumentEventMap do
  
  it "returns the proper instruments for an event" do
    
    instruments = InstrumentEventMap.instruments_for("Pregnancy Visit 1")
    instruments.should include "INS_QUE_PregVisit1_INT_EHPBHI_P2_V2.0"
    instruments.should include "INS_QUE_PregVisit1_SAQ_EHPBHI_P2_V2.0"
    instruments.should include "INS_BIO_AdultBlood_DCI_EHPBHI_P2_V1.0"
    instruments.should include "INS_BIO_AdultUrine_DCI_EHPBHI_P2_V1.0"
    instruments.should include "INS_ENV_TapWaterPharmTechCollect_DCI_EHPBHI_P2_V1.0"
    instruments.should include "INS_ENV_TapWaterPestTechCollect_DCI_EHPBHI_P2_V1.0"
    instruments.should include "INS_ENV_VacBagDustTechCollect_DCI_EHPBHI_P2_V1.0"
    instruments.size.should == 7
    
  end
  
  it "handles the epoch prefix given by psc" do
    instruments = InstrumentEventMap.instruments_for("HI-Intensity: Pregnancy Visit 1")
    instruments.size.should == 7
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
  
end


