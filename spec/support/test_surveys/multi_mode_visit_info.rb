def create_mmvis_survey_with_prepopulated_questions
  survey = Factory(:survey, :title => "INS_CON_MultiModeVisitInfo_DCI_EHPBHILIPBS_M3.0_1.0", :access_code => "ins-con-multimodevisitinfo-dci-ehpbhilipbs-m3-0-1-0")
  survey_section = Factory(:survey_section, :survey_id => survey.id)

  q = Factory(:question, :reference_identifier => "prepopulate_is_birth_or_subsequent_event", :survey_section_id => survey_section.id)
  a = Factory(:answer, :question_id => q.id, :text => "TRUE", :response_class => "answer", :reference_identifier => "true")
  a = Factory(:answer, :question_id => q.id, :text => "FALSE", :response_class => "answer", :reference_identifier => "false")

  q = Factory(:question, :reference_identifier => "prepopulated_mode_of_contact", :data_export_identifier => "prepopulated_mode_of_contact", :survey_section_id => survey_section.id)
  a = Factory(:answer, :question_id => q.id, :text => "CAPI", :response_class => "answer", :reference_identifier => "capi")
  a = Factory(:answer, :question_id => q.id, :text => "CATI", :response_class => "answer", :reference_identifier => "cati")
  a = Factory(:answer, :question_id => q.id, :text => "PAPI", :response_class => "answer", :reference_identifier => "papi")

  survey
end
