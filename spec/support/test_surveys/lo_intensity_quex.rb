# -*- coding: utf-8 -*-

module LoIntensityQuex
  def create_li_pregnancy_screener_survey_with_ppg_status_history_operational_data

    survey = Factory(:survey, :title => "INS_QUE_LIPregNotPreg_INT_LI_P2_V2.0", :access_code => "ins-que-lipregnotpreg-int-li-p2-v2-0")
    survey_section = Factory(:survey_section, :survey_id => survey.id)

    # Pregnant
    q = Factory(:question, :reference_identifier => "PREGNANT", :data_export_identifier => "PREG_VISIT_LI_2.PREGNANT", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Yes", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "No", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "No, recent loss", :response_class => "answer", :reference_identifier => "3")
    a = Factory(:answer, :question_id => q.id, :text => "No, recently gave birth", :response_class => "answer", :reference_identifier => "4")
    a = Factory(:answer, :question_id => q.id, :text => "No, unable to have children", :response_class => "answer", :reference_identifier => "5")
    # Due Date
    q = Factory(:question, :reference_identifier => "DUE_DATE", :data_export_identifier => "PREG_VISIT_LI_2.DUE_DATE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Due Date", :response_class => "date")

    survey
  end

  def create_lo_i_quex_with_prepopulated_ppg_status

    survey = Factory(:survey, :title => "INS_QUE_LIPregNotPreg_INT_LI_P2_V2.0", :access_code => "ins-que-lipregnotpreg-int-li-p2-v2-0")
    survey_section = Factory(:survey_section, :survey_id => survey.id)

    q = Factory(:question, :reference_identifier => "prepopulated_ppg_status", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "PPG Status", :response_class => "integer", :reference_identifier => "ppg_status")

    survey
  end

  def create_lo_i_quex_with_birth_institution_operational_data
    survey = Factory(:survey, :title => "INS_QUE_LIPregNotPreg_INT_LI_P2_V2.0", :access_code => "ins-que-lipregnotpreg-int-li-p2-v2-0")
    survey_section = Factory(:survey_section, :survey_id => survey.id)

    # Institution Type
    q = Factory(:question, :reference_identifier => "BIRTH_PLAN", :data_export_identifier => "PREG_VISIT_LI_2.BIRTH_PLAN", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "In a hospital,", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    # Institution Name
    q = Factory(:question, :reference_identifier => "BIRTH_PLACE", :data_export_identifier => "PREG_VISIT_LI_2.BIRTH_PLACE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "FAKE HOSPITAL MEMORIAL", :response_class => "string")
    # Address One
    q = Factory(:question, :reference_identifier => "B_ADDRESS_1", :data_export_identifier => "PREG_VISIT_LI_2.B_ADDRESS_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address 1", :response_class => "string")
    # Address Two
    q = Factory(:question, :reference_identifier => "B_ADDRESS_2", :data_export_identifier => "PREG_VISIT_LI_2.B_ADDRESS_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address 2", :response_class => "string")
    # City
    q = Factory(:question, :reference_identifier => "B_CITY", :data_export_identifier => "PREG_VISIT_LI_2.B_CITY", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "City", :response_class => "string")
    # State
    q = Factory(:question, :reference_identifier => "B_STATE", :data_export_identifier => "PREG_VISIT_LI_2.B_STATE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "IL", :response_class => "answer", :reference_identifier => "14")
    a = Factory(:answer, :question_id => q.id, :text => "MI", :response_class => "answer", :reference_identifier => "23")
    # Zip
    q = Factory(:question, :reference_identifier => "B_ZIPCODE", :data_export_identifier => "PREG_VISIT_LI_2.B_ZIPCODE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Zip", :response_class => "string")

    survey
  end

  def create_li_preg_not_preg_main_heat_survey
    load_survey_questions_string(<<-QUESTIONS)
      q_MAIN_HEAT "Which of these types of heat sources best describes the main heating fuel source for your home? Is it...",
      :help_text => "SHOW RESPONSE OPTIONS ON CARD TO PARTICIPANT.", :pick=>:one,
      :data_export_identifier=>"PREG_VISIT_LI_2.MAIN_HEAT"
      a_1 "ELECTRIC"
      a_2 "GAS - PROPANE OR LP"
      a_3 "OIL"
      a_4 "WOOD"
      a_5 "KEROSENE OR DIESEL"
      a_6 "COAL OR COKE"
      a_7 "SOLAR ENERGY"
      a_8 "HEAT PUMP"
      a_9 "NO HEATING SOURCE"
      a_neg_5 "OTHER"
      a_neg_1 "REFUSED"
      a_neg_2 "DON'T KNOW"

      q_TEST "Test question?",
      :pick => :any,
      :data_export_identifier=>"TEST_TABLE.TEST"
      a_9 "Other vitamins or supplements:"
    QUESTIONS
  end

end
