# -*- coding: utf-8 -*-

module MMother

  def create_18mm_v2_survey_for_mold_prepopulators
    survey = Factory(:survey, :title =>
              "INS_QUE_18MMother_INT_EHPBHI_M2.2_V2.0_EIGHTEEN_MTH_MOTHER_MOLD",
                     :access_code =>
              "ins_que_18mmother_int_ehpbhi_m2_2_V2_0_eighteen_mth_mother_mold")
    survey_section = Factory(:survey_section, :survey_id => survey.id)
    q = Factory(:question, :reference_identifier =>
                                   "prepopulated_should_show_room_mold_child",
                :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE",
                :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE",
                :response_class => "answer", :reference_identifier => "false")
    survey
  end

  def create_18mm_v2_survey_part_three_for_mold_prepopulators
    survey = Factory(:survey,
                     :title =>
                            "INS_QUE_18MMother_INT_EHPBHI_M2.2_V2.0_PART_THREE",
                     :access_code =>
                            "ins_que_18mmother_int_ehpbhi_m2_2_V2_0_part_three")
    survey_section = Factory(:survey_section, :survey_id => survey.id)
    q = Factory(:question,
                :reference_identifier => "MOLD",
                :data_export_identifier => "EIGHTEEN_MTH_MOTHER_2.MOLD",
                :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :reference_identifier => "1",
                :text => "YES", :response_class => "answer")
    a = Factory(:answer, :question_id => q.id, :reference_identifier => "2",
                :text => "NO", :response_class => "answer")
    a = Factory(:answer, :question_id => q.id, :text => "REFUSED",
                :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "DON'T KNOW",
                :response_class => "answer", :reference_identifier => "neg_2")
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

  def create_3mmmother_int_part_two
    survey = Factory(:survey, :title =>
              "INS_QUE_3MMother_INT_EHPBHI_P2_V1.1_PART_TWO",
                     :access_code =>
              "ins_que_3mmother_int_ehpbhi_p2_v1_1_part_two")
    survey_section = Factory(:survey_section, :survey_id => survey.id)
    q = Factory(:question, :reference_identifier =>
                                   "prepopulated_should_show_demographics",
                :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE",
                :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE",
                :response_class => "answer", :reference_identifier => "false")
    survey
  end

end
