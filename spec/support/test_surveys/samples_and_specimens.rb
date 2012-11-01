# -*- coding: utf-8 -*-

module SamplesAndSpecimens

  def create_adult_blood_survey_with_specimen_operational_data
    survey = Factory(:survey, :title => "INS_BIO_AdultBlood_DCI_EHPBHI_P2_V1.0", :access_code => "ins-bio-adultblood-dci-ehpbhi-p2-v1-0")
    survey_section = Factory(:survey_section, :survey_id => survey.id)

    8.times do |x|
      q = Factory(:question, :reference_identifier => "SPECIMEN_ID", :data_export_identifier => "SPEC_BLOOD_TUBE[tube_type=#{x+1}].SPECIMEN_ID", :survey_section_id => survey_section.id)
      a = Factory(:answer, :question_id => q.id, :text => "Tube barcode", :response_class => "string")
    end

    survey
  end

  def create_adult_urine_survey_with_specimen_operational_data
    survey = Factory(:survey, :title => "INS_BIO_AdultUrine_DCI_EHPBHI_P2_V1.0", :access_code => "ins-bio-adulturine-dci-ehpbhi-p2-v1-0")
    survey_section = Factory(:survey_section, :survey_id => survey.id)

    q = Factory(:question, :reference_identifier => "SPECIMEN_ID", :data_export_identifier => "SPEC_URINE.SPECIMEN_ID", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "urine collection cup specimen", :response_class => "string")

    survey
  end

  def create_cord_blood_survey_with_specimen_operational_data
    survey = Factory(:survey, :title => "INS_BIO_CordBlood_DCI_EHPBHI_P2_V1.0", :access_code => "ins-bio-cordblood-dci-ehpbhi-p2-v1-0")
    survey_section = Factory(:survey_section, :survey_id => survey.id)

    3.times do |x|
      q = Factory(:question, :reference_identifier => "SPECIMEN_ID", :data_export_identifier => "SPEC_CORD_BLOOD_SPECIMEN[cord_container=#{x+1}].SPECIMEN_ID", :survey_section_id => survey_section.id)
      a = Factory(:answer, :question_id => q.id, :text => "Tube barcode", :response_class => "string")
    end

    survey
  end

  def create_vacuum_bag_dust_survey_with_sample_operational_data
    survey = Factory(:survey, :title => "INS_ENV_VacBagDustTechCollect_DCI_EHPBHI_P2_V1.0", :access_code => "ins-env-vacbagdusttechcollect-dci-ehpbhi-p2-v1-0")
    survey_section = Factory(:survey_section, :survey_id => survey.id)

    q = Factory(:question, :reference_identifier => "SAMPLE_ID", :data_export_identifier => "VACUUM_BAG.SAMPLE_ID", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "vacuum bag dust sample ID", :response_class => "string")

    survey
  end

  def create_tap_water_survey_with_sample_operational_data
    survey = Factory(:survey, :title => "INS_ENV_TapWaterPharmTechCollect_DCI_EHPBHI_P2_V1.0", :access_code => "ins-env-tapwaterpharmtechcollect-dci-ehpbhi-p2-v1-0")
    survey_section = Factory(:survey_section, :survey_id => survey.id)

    3.times do |x|
      q = Factory(:question, :reference_identifier => "SAMPLE_ID", :data_export_identifier => "TAP_WATER_TWF_SAMPLE[sample_number=#{x+1}].SAMPLE_ID", :survey_section_id => survey_section.id)
      a = Factory(:answer, :question_id => q.id, :text => "sample id label", :response_class => "string")
    end

    survey
  end

  def create_tap_water_pest_survey_with_sample_operational_data
    survey = Factory(:survey, :title => "INS_ENV_TapWaterPestTechCollect_DCI_EHPBHI_P2_V1.0", :access_code => "ins-env-tapwaterpesttechcollect-dci-ehpbhi-p2-v1-0")
    survey_section = Factory(:survey_section, :survey_id => survey.id)

    3.times do |x|
      q = Factory(:question, :reference_identifier => "SAMPLE_ID", :data_export_identifier => "TAP_WATER_TWQ_SAMPLE[sample_number=#{x+1}].SAMPLE_ID", :survey_section_id => survey_section.id)
      a = Factory(:answer, :question_id => q.id, :text => "sample id label", :response_class => "string")
    end

    survey
  end
end