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
end