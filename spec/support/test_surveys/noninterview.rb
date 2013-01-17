# -*- coding: utf-8 -*-

module NonInterview

  def create_non_interview_survey_for_prepopulators
    survey = Factory(:survey,
                    :title => "INS_QUE_NonIntRespQues_INT_EHPBHILIPBS_M3.0_V1.0",
                    :access_code =>
                        "ins_que_nonintrespques_int_ehpbhilipbs_m3_0_v1_0")
    survey_section = Factory(:survey_section, :survey_id => survey.id)
    # prepopulated_is_declined_participation_prior_to_enrollment
    q = Factory(:question, :reference_identifier =>
                    "prepopulated_is_declined_participation_prior_to_enrollment",
                :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE",
                :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE",
                :response_class => "answer", :reference_identifier => "false")

    survey
  end

end
