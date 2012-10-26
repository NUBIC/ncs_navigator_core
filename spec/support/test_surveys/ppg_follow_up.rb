# -*- coding: utf-8 -*-

module PpgFollowUp

  def create_follow_up_survey_with_ppg_status_history_operational_data
    survey = Factory(:survey, :title => "INS_QUE_PPGFollUp_INT_EHPBHILI_P2_V1.2", :access_code => "ins-que-ppgfollup-int-ehpbhili-p2-v1-2")
    survey_section = Factory(:survey_section, :survey_id => survey.id)
    # Pregnant
    q = Factory(:question, :reference_identifier => "PREGNANT", :data_export_identifier => "PPG_CATI.PREGNANT", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Yes", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "No", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "No, recent loss", :response_class => "answer", :reference_identifier => "3")
    a = Factory(:answer, :question_id => q.id, :text => "No, unable to have children", :response_class => "answer", :reference_identifier => "4")
    # Due Date
    q = Factory(:question, :reference_identifier => "PPG_DUE_DATE_1", :data_export_identifier => "PPG_CATI.PPG_DUE_DATE_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Due Date", :response_class => "date")
    # Trying
    q = Factory(:question, :reference_identifier => "TRYING", :data_export_identifier => "PPG_CATI.TRYING", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Yes", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "No", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "No, recent loss", :response_class => "answer", :reference_identifier => "3")
    a = Factory(:answer, :question_id => q.id, :text => "No, recently gave birth", :response_class => "answer", :reference_identifier => "4")
    # Unable
    q = Factory(:question, :reference_identifier => "MED_UNABLE", :data_export_identifier => "PPG_CATI.MED_UNABLE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Yes", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "No", :response_class => "answer", :reference_identifier => "2")

    survey
  end

  def create_follow_up_survey_with_telephone_operational_data
    survey = Factory(:survey, :title => "INS_QUE_PPGFollUp_INT_EHPBHILI_P2_V1.2", :access_code => "ins-que-ppgfollup-int-ehpbhili-p2-v1-2")
    survey_section = Factory(:survey_section, :survey_id => survey.id)

    # Phone Number
    q = Factory(:question, :reference_identifier => "PHONE_NBR", :data_export_identifier => "PPG_CATI.PHONE_NBR", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Phone Number", :response_class => "string")
    # Type
    q = Factory(:question, :reference_identifier => "PHONE_TYPE", :data_export_identifier => "PPG_CATI.PHONE_TYPE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Home", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "Work", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "Cell", :response_class => "answer", :reference_identifier => "3")
    a = Factory(:answer, :question_id => q.id, :text => "Friend/Relative", :response_class => "answer", :reference_identifier => "4")
    a = Factory(:answer, :question_id => q.id, :text => "Other", :response_class => "answer", :reference_identifier => "5")

    survey
  end

  def create_follow_up_survey_with_contact_operational_data
    survey = Factory(:survey, :title => "INS_QUE_PPGFollUp_SAQ_EHPBHILI_P2_V1.1", :access_code => "ins-que-ppgfollup-saq-ehpbhili-p2-v1-1")
    survey_section = Factory(:survey_section, :survey_id => survey.id)
    # Email
    q = Factory(:question, :reference_identifier => "EMAIL", :data_export_identifier => "PPG_SAQ.EMAIL", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Email", :response_class => "string")
    # Home Phone
    q = Factory(:question, :reference_identifier => "HOME_PHONE", :data_export_identifier => "PPG_SAQ.HOME_PHONE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Phone Number", :response_class => "string")
    # Cell Phone
    q = Factory(:question, :reference_identifier => "CELL_PHONE", :data_export_identifier => "PPG_SAQ.CELL_PHONE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Phone Number", :response_class => "string")
    # Work Phone
    q = Factory(:question, :reference_identifier => "WORK_PHONE", :data_export_identifier => "PPG_SAQ.WORK_PHONE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Phone Number", :response_class => "string")
    # Other Phone
    q = Factory(:question, :reference_identifier => "OTHER_PHONE", :data_export_identifier => "PPG_SAQ.OTHER_PHONE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Phone Number", :response_class => "string")

    survey
  end

end