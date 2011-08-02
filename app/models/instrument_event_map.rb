class InstrumentEventMap
  
  def self.instruments_for(event)
    result = []
    case event
    when "Pregnancy Visit 1" 
      result << "INS_QUE_PregVisit1_INT_EHPBHI_P2_V2.0" # - Pregnancy Visit 1 Interview	
      # INS_QUE_PregVisit1_SAQ_EHPBHI_P2_V2.0 - Pregnancy Visit 1 SAQ 
      # 
      # INS_BIO_AdultBlood_DCI_EHPBHI_P2_V1.0 - Biospecimen Adult Blood Instrument
      # INS_BIO_AdultUrine_DCI_EHPBHI_P2_V1.0 - Biospecimen Adult Urine Instrument
      # 
      # INS_ENV_TapWaterPharmTechCollect_DCI_EHPBHI_P2_V1.0 - Environmental Tap Water Pharmaceuticals (TWF) Technician Collect Instrument 
      # INS_ENV_TapWaterPestTechCollect_DCI_EHPBHI_P2_V1.0  - Environmental Tap Water Pesticides (TWQ) Technician Collect Instrument  
      # INS_ENV_VacBagDustTechCollect_DCI_EHPBHI_P2_V1.0    - Environmental Vacuum Bag Dust (VBD) Technician Collect Instrument
    end
    result
  end
  
end