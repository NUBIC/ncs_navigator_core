# -*- coding: utf-8 -*-

module TestSurveys

  ##
  # Creates a ParticipantConsent for a {Person} person, {Participant} participant and {Survey} survey,
  # saves it, and returns it along with the associated ResponseSet.
  # @see ParticipantConsent.start!
  def prepare_consent(person, participant, survey, contact, contact_link)
    ParticipantConsent.start!(person, participant, survey, contact, contact_link)
  end

  ##
  # Starts an Instrument for a {Person} person, {Participant} participant and {Survey} survey,
  # saves it, and returns the created ResponseSet along with the Instrument.
  def prepare_instrument(person, participant, survey, mode = Instrument.capi, event = nil)
    instr = person.build_instrument(survey, mode)
    person.start_instrument(survey, participant, mode, event, instr)
    instr.save!

    instr.response_sets.first.responses.clear
    # TODO: update this method so that all response sets are returned - not just the first
    [instr.response_sets.first, instr]
  end

  def create_test_survey_for_person
    survey = Factory(:survey, :title => "INS_QUE_Something_INT_LI_P2_V2.0", :access_code => "ins-que-something-int-li-p2-v2-0")
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

  def create_generic_true_false_prepopulator_survey(survey_title,
                                                    reference_identifier)
    survey = Factory(:survey, :title => survey_title,
                     :access_code => survey_title.downcase.tr('.', '_'))
    survey_section = Factory(:survey_section, :survey_id => survey.id)
    q = Factory(:question, :reference_identifier => reference_identifier,
                :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE",
                :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE",
                :response_class => "answer", :reference_identifier => "false")
    survey
  end

end
