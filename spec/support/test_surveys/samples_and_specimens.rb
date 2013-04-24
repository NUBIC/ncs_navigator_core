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

    3.times do |x|
      q = Factory(:question, :reference_identifier => "SPECIMEN_ID", :data_export_identifier => "SPEC_CORD_BLOOD_SPECIMEN_2[collection_type=#{x+1}].SPECIMEN_ID", :survey_section_id => survey_section.id)
      a = Factory(:answer, :question_id => q.id, :text => "Tube barcode", :response_class => "string")
    end

    3.times do |x|
      q = Factory(:question, :reference_identifier => "SPECIMEN_ID", :data_export_identifier => "SPEC_CORD_BLOOD_SPECIMEN_3[collection_type=#{x+1}].SPECIMEN_ID", :survey_section_id => survey_section.id)
      a = Factory(:answer, :question_id => q.id, :text => "Tube barcode", :response_class => "string")
    end

    survey
  end

  def create_child_blood_survey_with_specimen_operational_data
    survey = Factory(:survey, :title => "INS_BIO_ChildBlood_INT_EHPBHI_M3.1_V1.0", :access_code => "ins_bio_childblood_int_ehpbhi_m3.1_v1.0")
    survey_section = Factory(:survey_section, :survey_id => survey.id)

    4.times do |x|
      q = Factory(:question, :reference_identifier => "SPECIMEN_ID", :data_export_identifier => "CHILD_BLOOD_TUBE[tube_type=#{x+1}].SPECIMEN_ID", :survey_section_id => survey_section.id)
      a = Factory(:answer, :question_id => q.id, :text => "tube barcode", :response_class => "string")
    end

    survey
  end

  def create_child_saliva_survey_with_specimen_operational_data
    survey = Factory(:survey, :title => "INS_BIO_ChildSalivaColl_INT_EHPBHI_M3.1_V1.0", :access_code => "ins_bio_childsalivacoll_int_ehpbhi_m3.1_v1.0")
    survey_section = Factory(:survey_section, :survey_id => survey.id)

    q = Factory(:question, :reference_identifier => "SPECIMEN_ID", :data_export_identifier => "CHILD_SALIVA.SPECIMEN_ID", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "tube barcode", :response_class => "string")

    survey
  end

  def create_child_urine_survey_with_specimen_operational_data
    survey = Factory(:survey, :title => "INS_BIO_ChildUrineColl_INT_EHPBHI_M3.1_V1.0", :access_code => "ins_bio_childurinecoll_int_ehpbhi_m3.1_v1.0")
    survey_section = Factory(:survey_section, :survey_id => survey.id)

    q = Factory(:question, :reference_identifier => "SPECIMEN_ID", :data_export_identifier => "CHILD_URINE.SPECIMEN_ID", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "tube barcode", :response_class => "string")

    survey
  end

  def create_breast_milk_survey_with_specimen_operational_data
    survey = Factory(:survey, :title => "INS_BIO_BreastMilkColl_SAQSpec_EHPBHI_M3.1_V1.0", :access_code => "ins_bio_breastmilkcoll_saqspec_ehpbhi_m3.1_v1.0")
    survey_section = Factory(:survey_section, :survey_id => survey.id)

    q = Factory(:question, :reference_identifier => "SPECIMEN_ID", :data_export_identifier => "BREAST_MILK_SAQ.SPECIMEN_ID", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "tube barcode", :response_class => "string")

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

  def create_sample_distrib_survey_with_sample_operational_data
    survey = Factory(:survey, :title => "INS_ENV_SampleDistrib_DCI_EHPBHI_M2.2_V1.0", :access_code => "ins_env_sampledistrib_dci_ehpbhi_m2.2_v1.0")
    survey_section = Factory(:survey_section, :survey_id => survey.id)

    3.times do |x|
      q = Factory(:question, :reference_identifier => "SAMPLE_ID", :data_export_identifier => "SAMPLE_DIST_SAMP[type=#{x+1}].SAMPLE_ID", :survey_section_id => survey_section.id)
      a = Factory(:answer, :question_id => q.id, :text => "sample id label", :response_class => "string")
    end

    survey
  end

  def create_adult_urine_specimen_status_survey
    load_survey_questions_string(<<-QUESTIONS)
      q_SPECIMEN_STATUS "URINE COLLECTION STATUS",
      :help_text => "THANK THE PARTICIPANT FOR THEIR SAMPLE (OR FOR TRYING IF NO SAMPLE WAS COLLECTED). ENTER THE STATUS OF THE URINE COLLECTION",
      :pick => :one,
      :data_export_identifier => "SPEC_URINE.SPECIMEN_STATUS"
      a_1 "COLLECTED"
      a_3 "NOT COLLECTED"

      q_TEST "Test question?",
      :pick => :any,
      :data_export_identifier=>"TEST_TABLE.TEST"
      a_3 "Other vitamins or supplements:"
    QUESTIONS
  end
end
