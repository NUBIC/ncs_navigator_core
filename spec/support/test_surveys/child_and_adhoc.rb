# -*- coding: utf-8 -*-

module ChildAndAdHoc

  def create_pm_child_bp_survey_for_upper_arm_circ_prepopulators 
    survey = Factory(:survey, :title => "INS_PM_ChildBP_DCI_EHPBHI_M3.1_V1.0",
                     :access_code => "ins_pm_childbp_dci_ehpbhi_m3_1_v1_0")
    survey_section = Factory(:survey_section, :survey_id => survey.id)
    q = Factory(:question, :reference_identifier =>
                                   "prepopulated_should_show_upper_arm_length",
                :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE",
                :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE",
                :response_class => "answer", :reference_identifier => "false")

    q = Factory(:question, :reference_identifier => "BP_MID_UPPER_ARM_CIRC",
                :data_export_identifier =>
                              "CHILD_BP.BP_MID_UPPER_ARM_CIRC",
                :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :response_class => "float",
                :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "REFUSED",
                :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "COULD NOT OBTAIN",
                :response_class => "answer", :reference_identifier => "neg_2")
    survey
  end

  def create_pm_child_anthr_survey_for_upper_arm_circ_prepopulators
    survey = Factory(:survey,
                     :title => "INS_PM_ChildAnthro_DCI_EHPBHI_M3.1_V1.0",
                     :access_code => "ins_pm_childanthro_dci_ehpbhi_m3_1_v1_0")
    survey_section = Factory(:survey_section, :survey_id => survey.id)
    q = Factory(:question,
                :reference_identifier => "AN_MID_UPPER_ARM_CIRC_1",
                :data_export_identifier =>
                              "CHILD_ANTHRO.AN_MID_UPPER_ARM_CIRC1",
                :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :reference_identifier => "1",
                :text => "MEASURED MID UPPER ARM CIRCUMFERENCE (CM)",
                :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "REFUSED",
                :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "COULD NOT OBTAIN",
                :response_class => "answer", :reference_identifier => "neg_8")
    survey
  end

  def create_pm_child_anthr_survey_for_6_month_event
    survey = Factory(:survey,
                     :title => "INS_PM_ChildAnthro_DCI_EHPBHI_M3.1_V1.0",
                     :access_code => "ins_pm_childanthro_dci_ehpbhi_m3_1_v1_0")
    survey_section = Factory(:survey_section, :survey_id => survey.id)
    q = Factory(:question,
                :reference_identifier => "prepopulated_is_6_month_event",
                :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE",
                :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE",
                :response_class => "answer", :reference_identifier => "false")
    survey
  end

  def create_bio_child_anthr_survey_for_12_month_visit
    survey = Factory(:survey,
                     :title => "INS_BIO_ChildBlood_INT_EHPBHI_M3.1_V1.0",
                     :access_code => "ins_bio_childblood_int_ehpbhi_m3_1_v1_0")
    survey_section = Factory(:survey_section, :survey_id => survey.id)
    q = Factory(:question,
                :reference_identifier => "prepopulated_is_12_month_visit",
                :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE",
                :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE",
                :response_class => "answer", :reference_identifier => "false")
    survey
  end

  def create_con_reconsideration_for_events
    survey = Factory(:survey,
                     :title => "INS_CON_Reconsideration_DCI_EHPBHI_M3.1_V1.0",
                     :access_code =>
                               "ins_con_reconsideration_dci_ehpbhi_m3_1_v1_0")
    survey_section = Factory(:survey_section, :survey_id => survey.id)
    q = Factory(:question,
                :reference_identifier => "prepopulated_event_type",
                :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "PV1 or PV2",
                :response_class => "answer", :reference_identifier => "pv")
    a = Factory(:answer, :question_id => q.id, :text => "12 MONTH",
                :response_class => "answer",
                :reference_identifier => "twelve_mns")
    survey
  end

end
