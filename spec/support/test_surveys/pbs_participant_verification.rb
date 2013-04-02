# -*- coding: utf-8 -*-

module PbsParticipantVerification
  def create_pbs_part_verification_with_part_two_survey_for_m3_2
    survey = Factory(:survey, :title => "INS_QUE_PBSPartVerBirth_INT_M3.2_V1.0_PART_TWO", :access_code => "ins_que_pbspartverbirth_int_m3.2_v1.0_part_two")
    survey_section = Factory(:survey_section, :survey_id => survey.id)

    # prepopulated_is_p_type_fifteen
    q = Factory(:question, :reference_identifier => "prepopulated_is_p_type_fifteen", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE", :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE", :response_class => "answer", :reference_identifier => "false")

    # Child Date of Birth
    q = Factory(:question, :reference_identifier => "CHILD_DOB", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Date of Birth", :response_class => "date", :reference_identifier => "date")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")

    survey
  end
end