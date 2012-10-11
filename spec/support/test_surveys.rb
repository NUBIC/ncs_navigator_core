# -*- coding: utf-8 -*-


module TestSurveys
  ##
  # Starts an Instrument for a {Person} p and {Survey} s, saves it, and
  # returns the created ResponseSet along with the Instrument.
  def prepare_instrument(person, participant, survey)
    instr = person.start_instrument(survey, participant)
    instr.save!

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

  def create_survey_with_language_and_interpreter_data
    survey = Factory(:survey, :title => "INS_QUE_PregScreen_INT_HILI_P2_V2.0", :access_code => "ins-que-pregscreen-int-hili-p2-v2-0")
    survey_section = Factory(:survey_section, :survey_id => survey.id)
    # English
    q = Factory(:question, :reference_identifier => "ENGLISH", :data_export_identifier => "PREG_SCREEN_HI_2.ENGLISH", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Yes", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "No", :response_class => "answer", :reference_identifier => "2")

    # Contact Language
    q = Factory(:question, :reference_identifier => "CONTACT_LANG", :data_export_identifier => "PREG_SCREEN_HI_2.CONTACT_LANG", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Spanish", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "Arabic",  :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "Farsi",   :response_class => "answer", :reference_identifier => "16")
    a = Factory(:answer, :question_id => q.id, :text => "Other",   :response_class => "answer", :reference_identifier => "-5")

    q = Factory(:question, :reference_identifier => "CONTACT_LANG_OTH", :data_export_identifier => "PREG_SCREEN_HI_2.CONTACT_LANG_OTH", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Specify", :response_class => "string")

    # Interpreter
    q = Factory(:question, :reference_identifier => "INTERPRET", :data_export_identifier => "PREG_SCREEN_HI_2.INTERPRET", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Yes", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "No", :response_class => "answer", :reference_identifier => "2")

    # Type of Interpreter
    q = Factory(:question, :reference_identifier => "CONTACT_INTERPRET", :data_export_identifier => "PREG_SCREEN_HI_2.CONTACT_INTERPRET", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Bilingual interviewer",              :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "In-person professional interpreter", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "Sign language interpreter",          :response_class => "answer", :reference_identifier => "6")
    a = Factory(:answer, :question_id => q.id, :text => "Other",                              :response_class => "answer", :reference_identifier => "-5")

    q = Factory(:question, :reference_identifier => "CONTACT_INTERPRET_OTH", :data_export_identifier => "PREG_SCREEN_HI_2.CONTACT_INTERPRET_OTH", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Specify", :response_class => "string")

    survey
  end

  def create_pregnancy_screener_survey_with_cell_phone_permissions
    survey = Factory(:survey, :title => "INS_QUE_PregScreen_INT_HILI_P2_V2.0", :access_code => "ins-que-pregscreen-int-hili-p2-v2-0")
    survey_section = Factory(:survey_section, :survey_id => survey.id)
    # Permission
    q = Factory(:question, :reference_identifier => "CELL_PHONE_2", :data_export_identifier => "PREG_SCREEN_HI_2.CELL_PHONE_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Yes", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "No", :response_class => "answer", :reference_identifier => "2")

    q = Factory(:question, :reference_identifier => "CELL_PHONE_4", :data_export_identifier => "PREG_SCREEN_HI_2.CELL_PHONE_4", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Yes", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "No", :response_class => "answer", :reference_identifier => "2")
    survey
  end

  def create_pregnancy_screener_survey_with_person_operational_data
    survey = Factory(:survey, :title => "INS_QUE_PregScreen_INT_HILI_P2_V2.0", :access_code => "ins-que-pregscreen-int-hili-p2-v2-0")
    survey_section = Factory(:survey_section, :survey_id => survey.id)
    # First name
    q = Factory(:question, :reference_identifier => "R_FNAME", :data_export_identifier => "PREG_SCREEN_HI_2.R_FNAME", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "First name", :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")
    # Last name
    q = Factory(:question, :reference_identifier => "R_LNAME", :data_export_identifier => "PREG_SCREEN_HI_2.R_LNAME", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Last name", :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")
    # Date of Birth
    q = Factory(:question, :reference_identifier => "PERSON_DOB", :data_export_identifier => "PREG_SCREEN_HI_2.PERSON_DOB", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Date of Birth", :response_class => "date")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")
    # Age
    q = Factory(:question, :reference_identifier => "AGE", :data_export_identifier => "PREG_SCREEN_HI_2.AGE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Age", :response_class => "integer")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")
    # Age Range
    q = Factory(:question, :reference_identifier => "AGE_RANGE", :data_export_identifier => "PREG_SCREEN_HI_2.AGE_RANGE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Less than 18", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "18-24", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "25-34", :response_class => "answer", :reference_identifier => "3")
    a = Factory(:answer, :question_id => q.id, :text => "35-44", :response_class => "answer", :reference_identifier => "4")
    a = Factory(:answer, :question_id => q.id, :text => "45-49", :response_class => "answer", :reference_identifier => "5")
    a = Factory(:answer, :question_id => q.id, :text => "50-64", :response_class => "answer", :reference_identifier => "6")
    a = Factory(:answer, :question_id => q.id, :text => "65 or older", :response_class => "answer", :reference_identifier => "7")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")
    # Ethnicity
    q = Factory(:question, :reference_identifier => "ETHNICITY", :data_export_identifier => "PREG_SCREEN_HI_2.ETHNICITY", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Yes", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "No", :response_class => "answer", :reference_identifier => "2")
    # Language
    q = Factory(:question, :reference_identifier => "PERSON_LANG", :data_export_identifier => "PREG_SCREEN_HI_2.PERSON_LANG", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "English", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "Spanish", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "Other", :response_class => "answer", :reference_identifier => "neg_5")
    # Specify Language
    q = Factory(:question, :reference_identifier => "PERSON_LANG_OTH", :data_export_identifier => "PREG_SCREEN_HI_2.PERSON_LANG_OTH", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Specify", :response_class => "string")

    # Age Eligible
    q = Factory(:question, :reference_identifier => "AGE_ELIG", :data_export_identifier => "PREG_SCREEN_HI_2.AGE_ELIG", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Age Eligible", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "Ineligible - too young", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "Ineligible - too old", :response_class => "answer", :reference_identifier => "3")

    survey
  end

  def create_pbs_eligibility_screener_survey_with_person_operational_data
    survey = Factory(:survey, :title => "INS_QUE_PBSamplingScreen_INT_PBS_M3.0_V1.0", :access_code => "ins-que-pbsamplingscreen-int-pbs-m3-0-v1-0")
    survey_section = Factory(:survey_section, :survey_id => survey.id)
    # First name
    q = Factory(:question, :reference_identifier => "R_FNAME", :data_export_identifier => "PBS_ELIG_SCREENER.R_FNAME", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "First name", :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")
    # Middle name
    q = Factory(:question, :reference_identifier => "R_MNAME", :data_export_identifier => "PBS_ELIG_SCREENER.R_MNAME", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Middle name", :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")
    # Last name
    q = Factory(:question, :reference_identifier => "R_LNAME", :data_export_identifier => "PBS_ELIG_SCREENER.R_LNAME", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Last name", :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")
    # Date of Birth
    q = Factory(:question, :reference_identifier => "PERSON_DOB", :data_export_identifier => "PBS_ELIG_SCREENER.PERSON_DOB", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Date of Birth", :response_class => "date")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")
    # Age Range PBS
    q = Factory(:question, :reference_identifier => "AGE_RANGE_PBS", :data_export_identifier => "PBS_ELIG_SCREENER.AGE_RANGE_PBS", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Less than 18", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "Over 18", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")
    # Ethnicity
    q = Factory(:question, :reference_identifier => "ETHNIC_ORIGIN", :data_export_identifier => "PBS_ELIG_SCREENER.ETHNIC_ORIGIN", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "No, not of Hispanic, Latina, or Spanish origin", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "Yes, Mexican, Mexican American, Chicana", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "Yes, Puerto Rican", :response_class => "answer", :reference_identifier => "3")
    a = Factory(:answer, :question_id => q.id, :text => "Yes, Cuban", :response_class => "answer", :reference_identifier => "4")
    a = Factory(:answer, :question_id => q.id, :text => "Yes, Another Hispanic, Latino, or Spanish origin", :response_class => "answer", :reference_identifier => "5")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")
    # Language
    q = Factory(:question, :reference_identifier => "PERSON_LANG_NEW", :data_export_identifier => "PBS_ELIG_SCREENER.PERSON_LANG_NEW", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "English", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "Spanish", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "Other", :response_class => "answer", :reference_identifier => "neg_5")
    # Specify Language
    q = Factory(:question, :reference_identifier => "PERSON_LANG_NEW_OTH", :data_export_identifier => "PBS_ELIG_SCREENER.PERSON_LANG_NEW_OTH", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Specify", :response_class => "string")

    # Age Eligible
    q = Factory(:question, :reference_identifier => "AGE_ELIG", :data_export_identifier => "PBS_ELIG_SCREENER.AGE_ELIG", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Age Eligible", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "Ineligible - too young", :response_class => "answer", :reference_identifier => "2")

    survey
  end

  def create_pregnancy_screener_survey_with_address_operational_data
    survey = Factory(:survey, :title => "INS_QUE_PregScreen_INT_HILI_P2_V2.0", :access_code => "ins-que-pregscreen-int-hili-p2-v2-0")
    survey_section = Factory(:survey_section, :survey_id => survey.id)

    # Address One
    q = Factory(:question, :reference_identifier => "ADDRESS_1", :data_export_identifier => "PREG_SCREEN_HI_2.ADDRESS_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address 1", :response_class => "string")
    # Address Two
    q = Factory(:question, :reference_identifier => "ADDRESS_2", :data_export_identifier => "PREG_SCREEN_HI_2.ADDRESS_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address 2", :response_class => "string")
    # Unit
    q = Factory(:question, :reference_identifier => "UNIT", :data_export_identifier => "PREG_SCREEN_HI_2.UNIT", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Unit", :response_class => "string")
    # City
    q = Factory(:question, :reference_identifier => "CITY", :data_export_identifier => "PREG_SCREEN_HI_2.CITY", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "City", :response_class => "string")
    # State
    q = Factory(:question, :reference_identifier => "STATE", :data_export_identifier => "PREG_SCREEN_HI_2.STATE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "IL", :response_class => "answer", :reference_identifier => "14")
    a = Factory(:answer, :question_id => q.id, :text => "MI", :response_class => "answer", :reference_identifier => "23")
    # Zip
    q = Factory(:question, :reference_identifier => "ZIP", :data_export_identifier => "PREG_SCREEN_HI_2.ZIP", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Zip", :response_class => "string")
    # plus 4
    q = Factory(:question, :reference_identifier => "ZIP4", :data_export_identifier => "PREG_SCREEN_HI_2.ZIP4", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "plus 4", :response_class => "string")

    survey
  end

  def create_tracing_module_survey_with_address_operational_data
    survey = Factory(:survey, :title => "INS_QUE_Tracing_INT_EHPBHILIPBS_M3.0_V1.0", :access_code => "ins-que-tracing-int-ehpbhilipbs-m3-0-v1-0")
    survey_section = Factory(:survey_section, :survey_id => survey.id)

    # Address One
    q = Factory(:question, :reference_identifier => "ADDRESS_1", :data_export_identifier => "TRACING_INT.ADDRESS_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address 1", :response_class => "string")
    # Address Two
    q = Factory(:question, :reference_identifier => "ADDRESS_2", :data_export_identifier => "TRACING_INT.ADDRESS_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address 2", :response_class => "string")
    # Unit
    q = Factory(:question, :reference_identifier => "UNIT", :data_export_identifier => "TRACING_INT.UNIT", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Unit", :response_class => "string")
    # City
    q = Factory(:question, :reference_identifier => "CITY", :data_export_identifier => "TRACING_INT.CITY", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "City", :response_class => "string")
    # State
    q = Factory(:question, :reference_identifier => "STATE", :data_export_identifier => "TRACING_INT.STATE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "IL", :response_class => "answer", :reference_identifier => "14")
    a = Factory(:answer, :question_id => q.id, :text => "MI", :response_class => "answer", :reference_identifier => "23")
    # Zip
    q = Factory(:question, :reference_identifier => "ZIP", :data_export_identifier => "TRACING_INT.ZIP", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Zip", :response_class => "string")
    # plus 4
    q = Factory(:question, :reference_identifier => "ZIP4", :data_export_identifier => "TRACING_INT.ZIP4", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "plus 4", :response_class => "string")

    survey
  end

  def create_tracing_module_survey_with_new_address_operational_data
    survey = Factory(:survey, :title => "INS_QUE_Tracing_INT_EHPBHILIPBS_M3.0_V1.0", :access_code => "ins-que-tracing-int-ehpbhilipbs-m3-0-v1-0")
    survey_section = Factory(:survey_section, :survey_id => survey.id)

    # Address One
    q = Factory(:question, :reference_identifier => "NEW_ADDRESS_1", :data_export_identifier => "TRACING_INT.NEW_ADDRESS_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address 1", :response_class => "string")
    # Address Two
    q = Factory(:question, :reference_identifier => "NEW_ADDRESS_2", :data_export_identifier => "TRACING_INT.NEW_ADDRESS_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address 2", :response_class => "string")
    # Unit
    q = Factory(:question, :reference_identifier => "NEW_UNIT", :data_export_identifier => "TRACING_INT.NEW_UNIT", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Unit", :response_class => "string")
    # City
    q = Factory(:question, :reference_identifier => "NEW_CITY", :data_export_identifier => "TRACING_INT.NEW_CITY", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "City", :response_class => "string")
    # State
    q = Factory(:question, :reference_identifier => "NEW_STATE", :data_export_identifier => "TRACING_INT.NEW_STATE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "IL", :response_class => "answer", :reference_identifier => "14")
    a = Factory(:answer, :question_id => q.id, :text => "MI", :response_class => "answer", :reference_identifier => "23")
    # Zip
    q = Factory(:question, :reference_identifier => "NEW_ZIP", :data_export_identifier => "TRACING_INT.NEW_ZIP", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Zip", :response_class => "string")
    # plus 4
    q = Factory(:question, :reference_identifier => "NEW_ZIP4", :data_export_identifier => "TRACING_INT.NEW_ZIP4", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "plus 4", :response_class => "string")

    survey
  end

  def create_pbs_eligibility_screener_survey_with_address_operational_data
    survey = Factory(:survey, :title => "INS_QUE_PBSamplingScreen_INT_PBS_M3.0_V1.0", :access_code => "ins-que-pbsamplingscreen-int-pbs-m3-0-v1-0")
    survey_section = Factory(:survey_section, :survey_id => survey.id)

    # Address One
    q = Factory(:question, :reference_identifier => "ADDRESS_1", :data_export_identifier => "PBS_ELIG_SCREENER.ADDRESS_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address 1", :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")
    # Address Two
    q = Factory(:question, :reference_identifier => "ADDRESS_2", :data_export_identifier => "PBS_ELIG_SCREENER.ADDRESS_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address 2", :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")
    # Unit
    q = Factory(:question, :reference_identifier => "UNIT", :data_export_identifier => "PBS_ELIG_SCREENER.UNIT", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Unit", :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")
    # City
    q = Factory(:question, :reference_identifier => "CITY", :data_export_identifier => "PBS_ELIG_SCREENER.CITY", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "City", :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")
    # State
    q = Factory(:question, :reference_identifier => "STATE", :data_export_identifier => "PBS_ELIG_SCREENER.STATE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "IL", :response_class => "answer", :reference_identifier => "14")
    a = Factory(:answer, :question_id => q.id, :text => "MI", :response_class => "answer", :reference_identifier => "23")
    # Zip
    q = Factory(:question, :reference_identifier => "ZIP", :data_export_identifier => "PBS_ELIG_SCREENER.ZIP", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Zip", :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")
    # plus 4
    q = Factory(:question, :reference_identifier => "ZIP4", :data_export_identifier => "PBS_ELIG_SCREENER.ZIP4", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "plus 4", :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")
    survey
  end

  def create_pregnancy_screener_survey_with_mail_address_operational_data
    survey = Factory(:survey, :title => "INS_QUE_PregScreen_INT_HILI_P2_V2.0", :access_code => "ins-que-pregscreen-int-hili-p2-v2-0")
    survey_section = Factory(:survey_section, :survey_id => survey.id)

    # Address One
    q = Factory(:question, :reference_identifier => "MAIL_ADDRESS_1", :data_export_identifier => "PREG_SCREEN_HI_2.MAIL_ADDRESS_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address 1", :response_class => "string")
    # Address Two
    q = Factory(:question, :reference_identifier => "MAIL_ADDRESS_2", :data_export_identifier => "PREG_SCREEN_HI_2.MAIL_ADDRESS_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address 2", :response_class => "string")
    # Unit
    q = Factory(:question, :reference_identifier => "MAIL_UNIT", :data_export_identifier => "PREG_SCREEN_HI_2.MAIL_UNIT", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Unit", :response_class => "string")
    # City
    q = Factory(:question, :reference_identifier => "MAIL_CITY", :data_export_identifier => "PREG_SCREEN_HI_2.MAIL_CITY", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "City", :response_class => "string")
    # State
    q = Factory(:question, :reference_identifier => "MAIL_STATE", :data_export_identifier => "PREG_SCREEN_HI_2.MAIL_STATE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "IL", :response_class => "answer", :reference_identifier => "14")
    a = Factory(:answer, :question_id => q.id, :text => "MI", :response_class => "answer", :reference_identifier => "23")
    # Zip
    q = Factory(:question, :reference_identifier => "MAIL_ZIP", :data_export_identifier => "PREG_SCREEN_HI_2.MAIL_ZIP", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Zip", :response_class => "string")
    # plus 4
    q = Factory(:question, :reference_identifier => "MAIL_ZIP4", :data_export_identifier => "PREG_SCREEN_HI_2.MAIL_ZIP4", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "plus 4", :response_class => "string")

    survey
  end

  def create_pregnancy_screener_survey_with_telephone_operational_data
    survey = Factory(:survey, :title => "INS_QUE_PregScreen_INT_HILI_P2_V2.0", :access_code => "ins-que-pregscreen-int-hili-p2-v2-0")
    survey_section = Factory(:survey_section, :survey_id => survey.id)

    # Phone Number
    q = Factory(:question, :reference_identifier => "PHONE_NBR", :data_export_identifier => "PREG_SCREEN_HI_2.PHONE_NBR", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Phone Number", :response_class => "string")
    # Phone Number other
    q = Factory(:question, :reference_identifier => "PHONE_NBR_OTH", :data_export_identifier => "PREG_SCREEN_HI_2.PHONE_NBR_OTH", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Phone Number", :response_class => "string")
    # Type
    q = Factory(:question, :reference_identifier => "PHONE_TYPE", :data_export_identifier => "PREG_SCREEN_HI_2.PHONE_TYPE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Home", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "Work", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "Cell", :response_class => "answer", :reference_identifier => "3")
    a = Factory(:answer, :question_id => q.id, :text => "Friend/Relative", :response_class => "answer", :reference_identifier => "4")
    a = Factory(:answer, :question_id => q.id, :text => "Other", :response_class => "answer", :reference_identifier => "5")
    # Type Other
    q = Factory(:question, :reference_identifier => "PHONE_TYPE_OTH", :data_export_identifier => "PREG_SCREEN_HI_2.PHONE_TYPE_OTH", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Specify", :response_class => "string")
    # Home Phone
    q = Factory(:question, :reference_identifier => "HOME_PHONE", :data_export_identifier => "PREG_SCREEN_HI_2.HOME_PHONE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Phone Number", :response_class => "string")
    # Cell Phone
    q = Factory(:question, :reference_identifier => "CELL_PHONE", :data_export_identifier => "PREG_SCREEN_HI_2.CELL_PHONE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Phone Number", :response_class => "string")
    # Can call cell?
    q = Factory(:question, :reference_identifier => "CELL_PHONE_2", :data_export_identifier => "PREG_SCREEN_HI_2.CELL_PHONE_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Yes", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "No", :response_class => "answer", :reference_identifier => "2")
    # Can text?
    q = Factory(:question, :reference_identifier => "CELL_PHONE_4", :data_export_identifier => "PREG_SCREEN_HI_2.CELL_PHONE_4", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Yes", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "No", :response_class => "answer", :reference_identifier => "2")

    survey
  end

  def create_tracing_module_survey_with_telephone_operational_data
    survey = Factory(:survey, :title => "INS_QUE_Tracing_INT_EHPBHILIPBS_M3.0_V1.0", :access_code => "ins-que-tracing-int-ehpbhilipbs-m3-0-v1-0")
    survey_section = Factory(:survey_section, :survey_id => survey.id)

    # Home Phone
    q = Factory(:question, :reference_identifier => "HOME_PHONE", :data_export_identifier => "TRACING_INT.HOME_PHONE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Phone Number", :response_class => "string")
    # Cell Phone
    q = Factory(:question, :reference_identifier => "CELL_PHONE", :data_export_identifier => "TRACING_INT.CELL_PHONE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Phone Number", :response_class => "string")
    # Can call cell?
    q = Factory(:question, :reference_identifier => "CELL_PHONE_2", :data_export_identifier => "TRACING_INT.CELL_PHONE_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Yes", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "No", :response_class => "answer", :reference_identifier => "2")
    # Can text?
    q = Factory(:question, :reference_identifier => "CELL_PHONE_4", :data_export_identifier => "TRACING_INT.CELL_PHONE_4", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Yes", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "No", :response_class => "answer", :reference_identifier => "2")

    survey
  end

  def create_pbs_eligibility_screener_survey_with_telephone_operational_data
    survey = Factory(:survey, :title => "INS_QUE_PBSamplingScreen_INT_PBS_M3.0_V1.0", :access_code => "ins-que-pbsamplingscreen-int-pbs-m3-0-v1-0")
    survey_section = Factory(:survey_section, :survey_id => survey.id)

    # Phone Number
    q = Factory(:question, :reference_identifier => "R_PHONE_1", :data_export_identifier => "PBS_ELIG_SCREENER.R_PHONE_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Phone Number", :response_class => "string")
    # Type
    q = Factory(:question, :reference_identifier => "R_PHONE_TYPE1", :data_export_identifier => "PBS_ELIG_SCREENER.R_PHONE_TYPE1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Home", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "Work", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "Cell", :response_class => "answer", :reference_identifier => "3")
    a = Factory(:answer, :question_id => q.id, :text => "Friend/Relative", :response_class => "answer", :reference_identifier => "4")
    a = Factory(:answer, :question_id => q.id, :text => "Other", :response_class => "answer", :reference_identifier => "5")
    # Type Other
    q = Factory(:question, :reference_identifier => "R_PHONE_TYPE1_OTH", :data_export_identifier => "PBS_ELIG_SCREENER.R_PHONE_TYPE1_OTH", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Specify", :response_class => "string")
    # Phone Number
    q = Factory(:question, :reference_identifier => "R_PHONE_2", :data_export_identifier => "PBS_ELIG_SCREENER.R_PHONE_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Phone Number", :response_class => "string")
    # Type
    q = Factory(:question, :reference_identifier => "R_PHONE_TYPE2", :data_export_identifier => "PBS_ELIG_SCREENER.R_PHONE_TYPE2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Home", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "Work", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "Cell", :response_class => "answer", :reference_identifier => "3")
    a = Factory(:answer, :question_id => q.id, :text => "Friend/Relative", :response_class => "answer", :reference_identifier => "4")
    a = Factory(:answer, :question_id => q.id, :text => "Other", :response_class => "answer", :reference_identifier => "5")
    # Type Other
    q = Factory(:question, :reference_identifier => "R_PHONE_TYPE2_OTH", :data_export_identifier => "PBS_ELIG_SCREENER.R_PHONE_TYPE2_OTH", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Specify", :response_class => "string")
    survey
  end

  def create_pregnancy_screener_survey_with_email_operational_data
    survey = Factory(:survey, :title => "INS_QUE_PregScreen_INT_HILI_P2_V2.0", :access_code => "ins-que-pregscreen-int-hili-p2-v2-0")
    survey_section = Factory(:survey_section, :survey_id => survey.id)
    # Email
    q = Factory(:question, :reference_identifier => "EMAIL", :data_export_identifier => "PREG_SCREEN_HI_2.EMAIL", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Email", :response_class => "string")
    # Type
    q = Factory(:question, :reference_identifier => "EMAIL_TYPE", :data_export_identifier => "PREG_SCREEN_HI_2.EMAIL_TYPE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Personal", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "Work", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "Family/Shared", :response_class => "answer", :reference_identifier => "3")
    survey
  end

  def create_pbs_eligibility_screener_survey_with_email_operational_data
    survey = Factory(:survey, :title => "INS_QUE_PBSamplingScreen_INT_PBS_M3.0_V1.0", :access_code => "ins-que-pbsamplingscreen-int-pbs-m3-0-v1-0")
    survey_section = Factory(:survey_section, :survey_id => survey.id)
    # Email
    q = Factory(:question, :reference_identifier => "R_EMAIL", :data_export_identifier => "PBS_ELIG_SCREENER.R_EMAIL", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Email", :response_class => "string")

    survey
  end

  def create_tracing_module_survey_with_email_operational_data
    survey = Factory(:survey, :title => "INS_QUE_Tracing_INT_EHPBHILIPBS_M3.0_V1.0", :access_code => "ins-que-tracing-int-ehpbhilipbs-m3-0-v1-0")
    survey_section = Factory(:survey_section, :survey_id => survey.id)
    # Email
    q = Factory(:question, :reference_identifier => "EMAIL", :data_export_identifier => "TRACING_INT.EMAIL", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Email", :response_class => "string")

    survey
  end

  def create_pregnancy_screener_survey_with_ppg_detail_operational_data
    survey = Factory(:survey, :title => "INS_QUE_PregScreen_INT_HILI_P2_V2.0", :access_code => "ins-que-pregscreen-int-hili-p2-v2-0")
    survey_section = Factory(:survey_section, :survey_id => survey.id)
    # Pregnant
    q = Factory(:question, :reference_identifier => "PREGNANT", :data_export_identifier => "PREG_SCREEN_HI_2.PREGNANT", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Yes", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "No", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "No, recent loss", :response_class => "answer", :reference_identifier => "3")
    a = Factory(:answer, :question_id => q.id, :text => "No, unable to have children", :response_class => "answer", :reference_identifier => "4")
    # Due Date
    q = Factory(:question, :reference_identifier => "ORIG_DUE_DATE", :data_export_identifier => "PREG_SCREEN_HI_2.ORIG_DUE_DATE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Due Date", :response_class => "date")
    # Trying
    q = Factory(:question, :reference_identifier => "TRYING", :data_export_identifier => "PREG_SCREEN_HI_2.TRYING", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Yes", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "No", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "No, recent loss", :response_class => "answer", :reference_identifier => "3")
    a = Factory(:answer, :question_id => q.id, :text => "No, recently gave birth", :response_class => "answer", :reference_identifier => "4")
    # PPG 5
    ["HYSTER", "OVARIES", "TUBES_TIED", "MENOPAUSE", "MED_UNABLE"].each do |reason|
      q = Factory(:question, :reference_identifier => reason, :data_export_identifier => "PREG_SCREEN_HI_2.#{reason}", :survey_section_id => survey_section.id)
      a = Factory(:answer, :question_id => q.id, :text => "Yes", :response_class => "answer", :reference_identifier => "1")
      a = Factory(:answer, :question_id => q.id, :text => "No", :response_class => "answer", :reference_identifier => "2")
    end
    q = Factory(:question, :reference_identifier => "MED_UNABLE_OTH", :data_export_identifier => "PREG_SCREEN_HI_2.MED_UNABLE_OTH", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Specify", :response_class => "string")
    survey
  end

  def create_pbs_eligibility_screener_survey_with_ppg_detail_operational_data
    survey = Factory(:survey, :title => "INS_QUE_PBSamplingScreen_INT_PBS_M3.0_V1.0", :access_code => "ins-que-pbsamplingscreen-int-pbs-m3-0-v1-0")
    survey_section = Factory(:survey_section, :survey_id => survey.id)
    # Pregnant
    q = Factory(:question, :reference_identifier => "PBS_ELIG_SCREENER", :data_export_identifier => "PBS_ELIG_SCREENER.PREGNANT", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Yes", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "No", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "No, recent loss", :response_class => "answer", :reference_identifier => "3")
    a = Factory(:answer, :question_id => q.id, :text => "No, unable to have children", :response_class => "answer", :reference_identifier => "5")
    survey
  end

  def create_pregnancy_screener_survey_to_determine_due_date
    survey = Factory(:survey, :title => "INS_QUE_PregScreen_INT_HILI_P2_V2.0", :access_code => "ins-que-pregscreen-int-hili-p2-v2-0")
    survey_section = Factory(:survey_section, :survey_id => survey.id)
    # Pregnant
    q = Factory(:question, :reference_identifier => "PREGNANT", :data_export_identifier => "PREG_SCREEN_HI_2.PREGNANT", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Yes", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "No", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "No, recent loss", :response_class => "answer", :reference_identifier => "3")
    a = Factory(:answer, :question_id => q.id, :text => "No, unable to have children", :response_class => "answer", :reference_identifier => "4")

    # Due Date
    q = Factory(:question, :reference_identifier => "ORIG_DUE_DATE", :data_export_identifier => "PREG_SCREEN_HI_2.ORIG_DUE_DATE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Due Date", :response_class => "date")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")

    # Date Last Period
    q = Factory(:question, :reference_identifier => "DATE_PERIOD", :data_export_identifier => "PREG_SCREEN_HI_2.DATE_PERIOD", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Date Last Period", :response_class => "date")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")

    # How Many Weeks Pregnant
    q = Factory(:question, :reference_identifier => "WEEKS_PREG", :data_export_identifier => "PREG_SCREEN_HI_2.WEEKS_PREG", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Weeks Pregnant", :response_class => "integer")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")

    # How Many Months Pregnant
    q = Factory(:question, :reference_identifier => "MONTH_PREG", :data_export_identifier => "PREG_SCREEN_HI_2.MONTH_PREG", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Months Pregnant", :response_class => "integer")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")

    # Which Trimester
    q = Factory(:question, :reference_identifier => "TRIMESTER", :data_export_identifier => "PREG_SCREEN_HI_2.TRIMESTER", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "1st trimester (1-3 months pregnant)", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "2nd trimester (4-6 months pregnant)", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "3rd trimester (7-9 months pregnant)", :response_class => "answer", :reference_identifier => "3")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")

    survey
  end

  def create_pbs_eligibility_screener_survey_to_determine_due_date
    survey = Factory(:survey, :title => "INS_QUE_PBSamplingScreen_INT_PBS_M3.0_V1.0", :access_code => "ins-que-pbsamplingscreen-int-pbs-m3-0-v1-0")
    survey_section = Factory(:survey_section, :survey_id => survey.id)
    # Pregnant
    q = Factory(:question, :reference_identifier => "PREGNANT", :data_export_identifier => "PBS_ELIG_SCREENER.PREGNANT", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Yes", :response_class => "answer", :reference_identifier => "1")

    # Due Date
    q = Factory(:question, :reference_identifier => "ORIG_DUE_DATE_MM", :data_export_identifier => "PBS_ELIG_SCREENER.ORIG_DUE_DATE_MM", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Due Date MM", :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")

    q = Factory(:question, :reference_identifier => "ORIG_DUE_DATE_DD", :data_export_identifier => "PBS_ELIG_SCREENER.ORIG_DUE_DATE_DD", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Due Date DD", :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")

    q = Factory(:question, :reference_identifier => "ORIG_DUE_DATE_YY", :data_export_identifier => "PBS_ELIG_SCREENER.ORIG_DUE_DATE_YY", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Due Date YY", :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")


    # Date Last Period
    q = Factory(:question, :reference_identifier => "DATE_PERIOD_MM", :data_export_identifier => "PBS_ELIG_SCREENER.DATE_PERIOD_MM", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Date Last Period MM", :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")

    q = Factory(:question, :reference_identifier => "DATE_PERIOD_DD", :data_export_identifier => "PBS_ELIG_SCREENER.DATE_PERIOD_DD", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Date Last Period DD", :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")

    q = Factory(:question, :reference_identifier => "DATE_PERIOD_YY", :data_export_identifier => "PBS_ELIG_SCREENER.DATE_PERIOD_YY", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Date Last Period YY", :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")

    # How Many Weeks Pregnant
    q = Factory(:question, :reference_identifier => "WEEKS_PREG", :data_export_identifier => "PBS_ELIG_SCREENER.WEEKS_PREG", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Weeks Pregnant", :response_class => "integer")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")

    # How Many Months Pregnant
    q = Factory(:question, :reference_identifier => "MONTH_PREG", :data_export_identifier => "PBS_ELIG_SCREENER.MONTH_PREG", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Months Pregnant", :response_class => "integer")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")

    # Which Trimester
    q = Factory(:question, :reference_identifier => "TRIMESTER", :data_export_identifier => "PBS_ELIG_SCREENER.TRIMESTER", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "1st trimester (1-3 months pregnant)", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "2nd trimester (4-6 months pregnant)", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "3rd trimester (7-9 months pregnant)", :response_class => "answer", :reference_identifier => "3")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")

    survey
  end


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

  def create_pre_pregnancy_survey_with_person_operational_data
    survey = Factory(:survey, :title => "INS_QUE_PrePreg_INT_EHPBHI_P2_V1.1", :access_code => "ins-que-prepreg-int-ehpbhi-p2-v1-1")
    survey_section = Factory(:survey_section, :survey_id => survey.id)
    # First name
    q = Factory(:question, :reference_identifier => "R_FNAME", :data_export_identifier => "PRE_PREG.R_FNAME", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "First name", :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")
    # Last name
    q = Factory(:question, :reference_identifier => "R_LNAME", :data_export_identifier => "PRE_PREG.R_LNAME", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Last name", :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")
    # Date of Birth
    q = Factory(:question, :reference_identifier => "PERSON_DOB", :data_export_identifier => "PRE_PREG.PERSON_DOB", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Date of Birth", :response_class => "date")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")
    # Martial Status
    q = Factory(:question, :reference_identifier => "MARISTAT", :data_export_identifier => "PRE_PREG.MARISTAT", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Married", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "Not married but living together", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "Never been married", :response_class => "answer", :reference_identifier => "3")
    a = Factory(:answer, :question_id => q.id, :text => "Divorced", :response_class => "answer", :reference_identifier => "4")
    a = Factory(:answer, :question_id => q.id, :text => "Separated", :response_class => "answer", :reference_identifier => "5")
    a = Factory(:answer, :question_id => q.id, :text => "Widowed", :response_class => "answer", :reference_identifier => "6")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")

    survey
  end

  def create_pre_pregnancy_survey_with_telephone_operational_data
    survey = Factory(:survey, :title => "INS_QUE_PrePreg_INT_EHPBHI_P2_V1.1", :access_code => "ins-que-prepreg-int-ehpbhi-p2-v1-1")
    survey_section = Factory(:survey_section, :survey_id => survey.id)

    # Cell Phone
    q = Factory(:question, :reference_identifier => "CELL_PHONE", :data_export_identifier => "PRE_PREG.CELL_PHONE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Phone Number", :response_class => "string")
    # Can call cell?
    q = Factory(:question, :reference_identifier => "CELL_PHONE_2", :data_export_identifier => "PRE_PREG.CELL_PHONE_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Yes", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "No", :response_class => "answer", :reference_identifier => "2")
    # Can text?
    q = Factory(:question, :reference_identifier => "CELL_PHONE_4", :data_export_identifier => "PRE_PREG.CELL_PHONE_4", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Yes", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "No", :response_class => "answer", :reference_identifier => "2")

    survey
  end

  def create_pre_pregnancy_survey_with_email_operational_data
    survey = Factory(:survey, :title => "INS_QUE_PrePreg_INT_EHPBHI_P2_V1.1", :access_code => "ins-que-prepreg-int-ehpbhi-p2-v1-1")
    survey_section = Factory(:survey_section, :survey_id => survey.id)

    # Email
    q = Factory(:question, :reference_identifier => "EMAIL", :data_export_identifier => "PRE_PREG.EMAIL", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Email", :response_class => "string")

    survey
  end

  def create_survey_with_many_sections
    survey = Factory(:survey, :title => "INS_QUE_PregScreen_INT_HILI_P2_V2.0", :access_code => "ins-que-pregscreen-int-hili-p2-v2-0")

    survey_section = Factory(:survey_section, :survey_id => survey.id)
    q = Factory(:question, :text => "Thank you for calling", :reference_identifier => nil, :data_export_identifier => "health_and_well_being_children", :survey_section_id => survey_section.id)

    survey_section = Factory(:survey_section, :survey_id => survey.id)
    # Pregnant
    q = Factory(:question, :reference_identifier => "PREGNANT", :data_export_identifier => "PREG_SCREEN_HI_2.PREGNANT", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Yes", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "No", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "No, recent loss", :response_class => "answer", :reference_identifier => "3")
    a = Factory(:answer, :question_id => q.id, :text => "No, recently gave birth", :response_class => "answer", :reference_identifier => "4")
    a = Factory(:answer, :question_id => q.id, :text => "No, unable to have children", :response_class => "answer", :reference_identifier => "5")
    # Due Date
    q = Factory(:question, :reference_identifier => "DUE_DATE", :data_export_identifier => "PREG_SCREEN_HI_2.DUE_DATE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Due Date", :response_class => "date")

    survey_section = Factory(:survey_section, :survey_id => survey.id)
    # Email
    q = Factory(:question, :reference_identifier => "EMAIL", :data_export_identifier => "PREG_SCREEN_HI_2.EMAIL", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Email", :response_class => "string")

    survey_section = Factory(:survey_section, :survey_id => survey.id)
    # English
    q = Factory(:question, :reference_identifier => "ENGLISH", :data_export_identifier => "PREG_SCREEN_HI_2.ENGLISH", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Yes", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "No", :response_class => "answer", :reference_identifier => "2")

    # Contact Language
    q = Factory(:question, :reference_identifier => "CONTACT_LANG", :data_export_identifier => "PREG_SCREEN_HI_2.CONTACT_LANG", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Spanish", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "Arabic",  :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "Farsi",   :response_class => "answer", :reference_identifier => "16")
    a = Factory(:answer, :question_id => q.id, :text => "Other",   :response_class => "answer", :reference_identifier => "-5")

    q = Factory(:question, :reference_identifier => "CONTACT_LANG_OTH", :data_export_identifier => "PREG_SCREEN_HI_2.CONTACT_LANG_OTH", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Specify", :response_class => "string")

    # Interpreter
    q = Factory(:question, :reference_identifier => "INTERPRET", :data_export_identifier => "PREG_SCREEN_HI_2.INTERPRET", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Yes", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "No", :response_class => "answer", :reference_identifier => "2")

    # Type of Interpreter
    q = Factory(:question, :reference_identifier => "CONTACT_INTERPRET", :data_export_identifier => "PREG_SCREEN_HI_2.CONTACT_INTERPRET", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Bilingual interviewer",              :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "In-person professional interpreter", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "Sign language interpreter",          :response_class => "answer", :reference_identifier => "6")
    a = Factory(:answer, :question_id => q.id, :text => "Other",                              :response_class => "answer", :reference_identifier => "-5")

    q = Factory(:question, :reference_identifier => "CONTACT_INTERPRET_OTH", :data_export_identifier => "PREG_SCREEN_HI_2.CONTACT_INTERPRET_OTH", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Specify", :response_class => "string")

    # End script
    survey_section = Factory(:survey_section, :survey_id => survey.id)
    q = Factory(:question, :text => "Thank you again", :reference_identifier => nil, :data_export_identifier => "thanks_again", :survey_section_id => survey_section.id)

    survey

  end

  # CONTACT_FNAME_1       Person.first_name
  # CONTACT_LNAME_1       Person.last_name
  #
  # CONTACT_RELATE_1      ParticipantPersonLink.relationship_code   PERSON_PARTCPNT_RELTNSHP_CL1/CONTACT_RELATIONSHIP_CL2
  # CONTACT_RELATE1_OTH   ParticipantPersonLink.relationship_other
  #
  # C_ADDR_1_1            Address.address_one
  # C_ADDR_2_1            Address.address_two
  # C_UNIT_1              Address.unit
  # C_CITY_1              Address.city
  # C_STATE_1             Address.state_code                        STATE_CL1
  # C_ZIP_1               Address.zip
  # C_ZIP4_1              Address.zip4
  #
  # CONTACT_PHONE_1       Telephone.phone_nbr
  def create_pre_pregnancy_survey_with_contact_operational_data
    survey = Factory(:survey, :title => "INS_QUE_PrePreg_INT_EHPBHI_P2_V1.1", :access_code => "ins-que-prepreg-int-ehpbhi-p2-v1-1")
    survey_section = Factory(:survey_section, :survey_id => survey.id)

    # Contact 1 First Name
    q = Factory(:question, :reference_identifier => "CONTACT_FNAME_1", :data_export_identifier => "PRE_PREG.CONTACT_FNAME_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "First Name", :response_class => "string")
    # Contact 1 Last Name
    q = Factory(:question, :reference_identifier => "CONTACT_LNAME_1", :data_export_identifier => "PRE_PREG.CONTACT_LNAME_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Last Name", :response_class => "string")
    # Contact 1 Relationship Code
    q = Factory(:question, :reference_identifier => "CONTACT_RELATE_1", :data_export_identifier => "PRE_PREG.CONTACT_RELATE_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "MOTHER/FATHER", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "BROTHER/SISTER", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "AUNT/UNCLE", :response_class => "answer", :reference_identifier => "3")
    a = Factory(:answer, :question_id => q.id, :text => "GRANDPARENT", :response_class => "answer", :reference_identifier => "4")
    a = Factory(:answer, :question_id => q.id, :text => "NEIGHBOR", :response_class => "answer", :reference_identifier => "5")
    a = Factory(:answer, :question_id => q.id, :text => "FRIEND", :response_class => "answer", :reference_identifier => "6")
    a = Factory(:answer, :question_id => q.id, :text => "OTHER", :response_class => "answer", :reference_identifier => "neg_5")
    # Contact 1 Relationship Other
    q = Factory(:question, :reference_identifier => "CONTACT_RELATE1_OTH", :data_export_identifier => "PRE_PREG.CONTACT_RELATE1_OTH", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Specify", :response_class => "string")
    # Contact 1 Address One
    q = Factory(:question, :reference_identifier => "C_ADDR_1_1", :data_export_identifier => "PRE_PREG.C_ADDR_1_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address 1", :response_class => "string")
    # Contact 1 Address Two
    q = Factory(:question, :reference_identifier => "C_ADDR_2_1", :data_export_identifier => "PRE_PREG.C_ADDR_2_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address 2", :response_class => "string")
    # Contact 1 Unit
    q = Factory(:question, :reference_identifier => "C_UNIT_1", :data_export_identifier => "PRE_PREG.C_UNIT_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Unit", :response_class => "string")
    # Contact 1 City
    q = Factory(:question, :reference_identifier => "C_CITY_1", :data_export_identifier => "PRE_PREG.C_CITY_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "City", :response_class => "string")
    # Contact 1 State
    q = Factory(:question, :reference_identifier => "C_STATE_1", :data_export_identifier => "PRE_PREG.C_STATE_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "IL", :response_class => "answer", :reference_identifier => "14")
    a = Factory(:answer, :question_id => q.id, :text => "MI", :response_class => "answer", :reference_identifier => "23")
    # Contact 1 Zip
    q = Factory(:question, :reference_identifier => "C_ZIP_1", :data_export_identifier => "PRE_PREG.C_ZIP_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Zip", :response_class => "string")
    # Contact 1 plus 4
    q = Factory(:question, :reference_identifier => "C_ZIP4_1", :data_export_identifier => "PRE_PREG.C_ZIP4_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "plus 4", :response_class => "string")
    # Contact 1 phone
    q = Factory(:question, :reference_identifier => "CONTACT_PHONE_1", :data_export_identifier => "PRE_PREG.CONTACT_PHONE_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Phone Number", :response_class => "string")

    # Contact 2 First Name
    q = Factory(:question, :reference_identifier => "CONTACT_FNAME_2", :data_export_identifier => "PRE_PREG.CONTACT_FNAME_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "First Name", :response_class => "string")
    # Contact 2 Last Name
    q = Factory(:question, :reference_identifier => "CONTACT_LNAME_2", :data_export_identifier => "PRE_PREG.CONTACT_LNAME_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Last Name", :response_class => "string")
    # Contact 2 Relationship Code
    q = Factory(:question, :reference_identifier => "CONTACT_RELATE_2", :data_export_identifier => "PRE_PREG.CONTACT_RELATE_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "MOTHER/FATHER", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "BROTHER/SISTER", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "AUNT/UNCLE", :response_class => "answer", :reference_identifier => "3")
    a = Factory(:answer, :question_id => q.id, :text => "GRANDPARENT", :response_class => "answer", :reference_identifier => "4")
    a = Factory(:answer, :question_id => q.id, :text => "NEIGHBOR", :response_class => "answer", :reference_identifier => "5")
    a = Factory(:answer, :question_id => q.id, :text => "FRIEND", :response_class => "answer", :reference_identifier => "6")
    a = Factory(:answer, :question_id => q.id, :text => "OTHER", :response_class => "answer", :reference_identifier => "neg_5")
    # Contact 2 Relationship Other
    q = Factory(:question, :reference_identifier => "CONTACT_RELATE2_OTH", :data_export_identifier => "PRE_PREG.CONTACT_RELATE2_OTH", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Specify", :response_class => "string")
    # Contact 2 Address One
    q = Factory(:question, :reference_identifier => "C_ADDR_1_2", :data_export_identifier => "PRE_PREG.C_ADDR_1_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address 1", :response_class => "string")
    # Contact 2 Address Two
    q = Factory(:question, :reference_identifier => "C_ADDR_2_2", :data_export_identifier => "PRE_PREG.C_ADDR_2_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address 2", :response_class => "string")
    # Contact 2 Unit
    q = Factory(:question, :reference_identifier => "C_UNIT_2", :data_export_identifier => "PRE_PREG.C_UNIT_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Unit", :response_class => "string")
    # Contact 2 City
    q = Factory(:question, :reference_identifier => "C_CITY_2", :data_export_identifier => "PRE_PREG.C_CITY_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "City", :response_class => "string")
    # Contact 2 State
    q = Factory(:question, :reference_identifier => "C_STATE_2", :data_export_identifier => "PRE_PREG.C_STATE_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "IL", :response_class => "answer", :reference_identifier => "14")
    a = Factory(:answer, :question_id => q.id, :text => "MI", :response_class => "answer", :reference_identifier => "23")
    # Contact 2 Zip
    q = Factory(:question, :reference_identifier => "C_ZIP_2", :data_export_identifier => "PRE_PREG.C_ZIP_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Zip", :response_class => "string")
    # Contact 2 plus 4
    q = Factory(:question, :reference_identifier => "C_ZIP4_2", :data_export_identifier => "PRE_PREG.C_ZIP4_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "plus 4", :response_class => "string")
    # Contact 2 phone
    q = Factory(:question, :reference_identifier => "CONTACT_PHONE_2", :data_export_identifier => "PRE_PREG.CONTACT_PHONE_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Phone Number", :response_class => "string")
    survey
  end

  def create_tracing_module_survey_with_contact_operational_data
    survey = Factory(:survey, :title => "INS_QUE_Tracing_INT_EHPBHILIPBS_M3.0_V1.0", :access_code => "ins-que-tracing-int-ehpbhilipbs-m3-0-v1-0")
    survey_section = Factory(:survey_section, :survey_id => survey.id)

    # Contact 1 First Name
    q = Factory(:question, :reference_identifier => "CONTACT_FNAME_1", :data_export_identifier => "TRACING_INT.CONTACT_FNAME_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "First Name", :response_class => "string")
    # Contact 1 Last TRACING_INT
    q = Factory(:question, :reference_identifier => "CONTACT_LNAME_1", :data_export_identifier => "TRACING_INT.CONTACT_LNAME_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Last Name", :response_class => "string")
    # Contact 1 Relationship Code
    q = Factory(:question, :reference_identifier => "CONTACT_RELATE_1", :data_export_identifier => "TRACING_INT.CONTACT_RELATE_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "MOTHER/FATHER", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "BROTHER/SISTER", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "AUNT/UNCLE", :response_class => "answer", :reference_identifier => "3")
    a = Factory(:answer, :question_id => q.id, :text => "GRANDPARENT", :response_class => "answer", :reference_identifier => "4")
    a = Factory(:answer, :question_id => q.id, :text => "NEIGHBOR", :response_class => "answer", :reference_identifier => "5")
    a = Factory(:answer, :question_id => q.id, :text => "FRIEND", :response_class => "answer", :reference_identifier => "6")
    a = Factory(:answer, :question_id => q.id, :text => "OTHER", :response_class => "answer", :reference_identifier => "neg_5")
    # Contact 1 Relationship Other
    q = Factory(:question, :reference_identifier => "CONTACT_RELATE1_OTH", :data_export_identifier => "TRACING_INT.CONTACT_RELATE1_OTH", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Specify", :response_class => "string")
    # Contact 1 Address One
    q = Factory(:question, :reference_identifier => "C_ADDR_1_1", :data_export_identifier => "TRACING_INT.C_ADDR1_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address 1", :response_class => "string")
    # Contact 1 Address Two
    q = Factory(:question, :reference_identifier => "C_ADDR_2_1", :data_export_identifier => "TRACING_INT.C_ADDR2_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address 2", :response_class => "string")
    # Contact 1 Unit
    q = Factory(:question, :reference_identifier => "C_UNIT_1", :data_export_identifier => "TRACING_INT.C_UNIT_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Unit", :response_class => "string")
    # Contact 1 City
    q = Factory(:question, :reference_identifier => "C_CITY_1", :data_export_identifier => "TRACING_INT.C_CITY_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "City", :response_class => "string")
    # Contact 1 State
    q = Factory(:question, :reference_identifier => "C_STATE_1", :data_export_identifier => "TRACING_INT.C_STATE_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "IL", :response_class => "answer", :reference_identifier => "14")
    a = Factory(:answer, :question_id => q.id, :text => "MI", :response_class => "answer", :reference_identifier => "23")
    # Contact 1 Zip
    q = Factory(:question, :reference_identifier => "C_ZIPCODE_1", :data_export_identifier => "TRACING_INT.C_ZIPCODE_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Zip", :response_class => "string")
    # Contact 1 plus 4
    q = Factory(:question, :reference_identifier => "C_ZIP4_1", :data_export_identifier => "TRACING_INT.C_ZIP4_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "plus 4", :response_class => "string")
    # Contact 1 phone
    q = Factory(:question, :reference_identifier => "CONTACT_PHONE_1", :data_export_identifier => "TRACING_INT.CONTACT_PHONE_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Phone Number", :response_class => "string")
    # Contact 1 phone type
    q = Factory(:question, :reference_identifier => "CONTACT_PHONE1_TYPE_1", :data_export_identifier => "TRACING_INT.CONTACT_PHONE1_TYPE_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Home", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "Work", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "Cell", :response_class => "answer", :reference_identifier => "3")
    a = Factory(:answer, :question_id => q.id, :text => "Friend/Relative", :response_class => "answer", :reference_identifier => "4")
    a = Factory(:answer, :question_id => q.id, :text => "Other", :response_class => "answer", :reference_identifier => "5")
    # Type Other
    q = Factory(:question, :reference_identifier => "CONTACT_PHONE1_TYPE_1_OTH", :data_export_identifier => "TRACING_INT.CONTACT_PHONE1_TYPE_1_OTH", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Specify", :response_class => "string")
    # Contact 1 phone
    q = Factory(:question, :reference_identifier => "CONTACT_PHONE_2_1", :data_export_identifier => "TRACING_INT.CONTACT_PHONE_2_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Phone Number", :response_class => "string")
    # Contact 1 phone type
    q = Factory(:question, :reference_identifier => "CONTACT_PHONE2_TYPE_1", :data_export_identifier => "TRACING_INT.CONTACT_PHONE2_TYPE_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Home", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "Work", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "Cell", :response_class => "answer", :reference_identifier => "3")
    a = Factory(:answer, :question_id => q.id, :text => "Friend/Relative", :response_class => "answer", :reference_identifier => "4")
    a = Factory(:answer, :question_id => q.id, :text => "Other", :response_class => "answer", :reference_identifier => "5")
    # Type Other
    q = Factory(:question, :reference_identifier => "CONTACT_PHONE2_TYPE_1_OTH", :data_export_identifier => "TRACING_INT.CONTACT_PHONE2_TYPE_1_OTH", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Specify", :response_class => "string")

    # Contact 2 First Name
    q = Factory(:question, :reference_identifier => "CONTACT_FNAME_2", :data_export_identifier => "TRACING_INT.CONTACT_FNAME_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "First Name", :response_class => "string")
    # Contact 2 Last Name
    q = Factory(:question, :reference_identifier => "CONTACT_LNAME_2", :data_export_identifier => "TRACING_INT.CONTACT_LNAME_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Last Name", :response_class => "string")
    # Contact 2 Relationship Code
    q = Factory(:question, :reference_identifier => "CONTACT_RELATE_2", :data_export_identifier => "TRACING_INT.CONTACT_RELATE_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "MOTHER/FATHER", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "BROTHER/SISTER", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "AUNT/UNCLE", :response_class => "answer", :reference_identifier => "3")
    a = Factory(:answer, :question_id => q.id, :text => "GRANDPARENT", :response_class => "answer", :reference_identifier => "4")
    a = Factory(:answer, :question_id => q.id, :text => "NEIGHBOR", :response_class => "answer", :reference_identifier => "5")
    a = Factory(:answer, :question_id => q.id, :text => "FRIEND", :response_class => "answer", :reference_identifier => "6")
    a = Factory(:answer, :question_id => q.id, :text => "OTHER", :response_class => "answer", :reference_identifier => "neg_5")
    # Contact 2 Relationship Other
    q = Factory(:question, :reference_identifier => "CONTACT_RELATE2_OTH", :data_export_identifier => "TRACING_INT.CONTACT_RELATE2_OTH", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Specify", :response_class => "string")
    # Contact 2 Address One
    q = Factory(:question, :reference_identifier => "C_ADDR_1_2", :data_export_identifier => "TRACING_INT.C_ADDR1_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address 1", :response_class => "string")
    # Contact 2 Address Two
    q = Factory(:question, :reference_identifier => "C_ADDR_2_2", :data_export_identifier => "TRACING_INT.C_ADDR_2_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address 2", :response_class => "string")
    # Contact 2 Unit
    q = Factory(:question, :reference_identifier => "C_UNIT_2", :data_export_identifier => "TRACING_INT.C_UNIT_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Unit", :response_class => "string")
    # Contact 2 City
    q = Factory(:question, :reference_identifier => "C_CITY_2", :data_export_identifier => "TRACING_INT.C_CITY_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "City", :response_class => "string")
    # Contact 2 State
    q = Factory(:question, :reference_identifier => "C_STATE_2", :data_export_identifier => "TRACING_INT.C_STATE_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "IL", :response_class => "answer", :reference_identifier => "14")
    a = Factory(:answer, :question_id => q.id, :text => "MI", :response_class => "answer", :reference_identifier => "23")
    # Contact 2 Zip
    q = Factory(:question, :reference_identifier => "C_ZIPCODE_2", :data_export_identifier => "TRACING_INT.C_ZIPCODE_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Zip", :response_class => "string")
    # Contact 2 plus 4
    q = Factory(:question, :reference_identifier => "C_ZIP4_2", :data_export_identifier => "TRACING_INT.C_ZIP4_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "plus 4", :response_class => "string")
    # Contact 2 phone
    q = Factory(:question, :reference_identifier => "CONTACT_PHONE_2", :data_export_identifier => "TRACING_INT.CONTACT_PHONE_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Phone Number", :response_class => "string")
    # Contact 2 phone type
    q = Factory(:question, :reference_identifier => "CONTACT_PHONE1_TYPE_2", :data_export_identifier => "TRACING_INT.CONTACT_PHONE1_TYPE_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Home", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "Work", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "Cell", :response_class => "answer", :reference_identifier => "3")
    a = Factory(:answer, :question_id => q.id, :text => "Friend/Relative", :response_class => "answer", :reference_identifier => "4")
    a = Factory(:answer, :question_id => q.id, :text => "Other", :response_class => "answer", :reference_identifier => "5")
    # Type Other
    q = Factory(:question, :reference_identifier => "CONTACT_PHONE1_TYPE_2_OTH", :data_export_identifier => "TRACING_INT.CONTACT_PHONE1_TYPE_2_OTH", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Specify", :response_class => "string")
    # Contact 2 phone
    q = Factory(:question, :reference_identifier => "CONTACT_PHONE_2_2", :data_export_identifier => "TRACING_INT.CONTACT_PHONE_2_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Phone Number", :response_class => "string")
    # Contact 2 phone type
    q = Factory(:question, :reference_identifier => "CONTACT_PHONE2_TYPE_2", :data_export_identifier => "TRACING_INT.CONTACT_PHONE2_TYPE_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Home", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "Work", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "Cell", :response_class => "answer", :reference_identifier => "3")
    a = Factory(:answer, :question_id => q.id, :text => "Friend/Relative", :response_class => "answer", :reference_identifier => "4")
    a = Factory(:answer, :question_id => q.id, :text => "Other", :response_class => "answer", :reference_identifier => "5")
    # Type Other
    q = Factory(:question, :reference_identifier => "CONTACT_PHONE2_TYPE_2_OTH", :data_export_identifier => "TRACING_INT.CONTACT_PHONE2_TYPE_2_OTH", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Specify", :response_class => "string")

    # Contact 3 First Name
    q = Factory(:question, :reference_identifier => "CONTACT_FNAME_3", :data_export_identifier => "TRACING_INT.CONTACT_FNAME_3", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "First Name", :response_class => "string")
    # Contact 3 Last Name
    q = Factory(:question, :reference_identifier => "CONTACT_LNAME_3", :data_export_identifier => "TRACING_INT.CONTACT_LNAME_3", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Last Name", :response_class => "string")
    # Contact 3 Relationship Code
    q = Factory(:question, :reference_identifier => "CONTACT_RELATE_3", :data_export_identifier => "TRACING_INT.CONTACT_RELATE_3", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "MOTHER/FATHER", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "BROTHER/SISTER", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "AUNT/UNCLE", :response_class => "answer", :reference_identifier => "3")
    a = Factory(:answer, :question_id => q.id, :text => "GRANDPARENT", :response_class => "answer", :reference_identifier => "4")
    a = Factory(:answer, :question_id => q.id, :text => "NEIGHBOR", :response_class => "answer", :reference_identifier => "5")
    a = Factory(:answer, :question_id => q.id, :text => "FRIEND", :response_class => "answer", :reference_identifier => "6")
    a = Factory(:answer, :question_id => q.id, :text => "OTHER", :response_class => "answer", :reference_identifier => "neg_5")
    # Contact 3 Relationship Other
    q = Factory(:question, :reference_identifier => "CONTACT_RELATE3_OTH", :data_export_identifier => "TRACING_INT.CONTACT_RELATE3_OTH", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Specify", :response_class => "string")
    # Contact 3 Address One
    q = Factory(:question, :reference_identifier => "C_ADDR_1_2", :data_export_identifier => "TRACING_INT.C_ADDR1_3", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address 1", :response_class => "string")
    # Contact 3 Address Two
    q = Factory(:question, :reference_identifier => "C_ADDR_2_2", :data_export_identifier => "TRACING_INT.C_ADDR_2_3", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address 2", :response_class => "string")
    # Contact 3 Unit
    q = Factory(:question, :reference_identifier => "C_UNIT_2", :data_export_identifier => "TRACING_INT.C_UNIT_3", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Unit", :response_class => "string")
    # Contact 3 City
    q = Factory(:question, :reference_identifier => "C_CITY_2", :data_export_identifier => "TRACING_INT.C_CITY_3", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "City", :response_class => "string")
    # Contact 3 State
    q = Factory(:question, :reference_identifier => "C_STATE_2", :data_export_identifier => "TRACING_INT.C_STATE_3", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "IL", :response_class => "answer", :reference_identifier => "14")
    a = Factory(:answer, :question_id => q.id, :text => "MI", :response_class => "answer", :reference_identifier => "23")
    # Contact 3 Zip
    q = Factory(:question, :reference_identifier => "C_ZIPCODE_3", :data_export_identifier => "TRACING_INT.C_ZIPCODE_3", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Zip", :response_class => "string")
    # Contact 3 plus 4
    q = Factory(:question, :reference_identifier => "C_ZIP4_3", :data_export_identifier => "TRACING_INT.C_ZIP4_3", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "plus 4", :response_class => "string")
    # Contact 3 phone
    q = Factory(:question, :reference_identifier => "CONTACT_PHONE_3", :data_export_identifier => "TRACING_INT.CONTACT_PHONE_3", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Phone Number", :response_class => "string")
    # Contact 3 phone type
    q = Factory(:question, :reference_identifier => "CONTACT_PHONE1_TYPE_3", :data_export_identifier => "TRACING_INT.CONTACT_PHONE1_TYPE_3", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Home", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "Work", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "Cell", :response_class => "answer", :reference_identifier => "3")
    a = Factory(:answer, :question_id => q.id, :text => "Friend/Relative", :response_class => "answer", :reference_identifier => "4")
    a = Factory(:answer, :question_id => q.id, :text => "Other", :response_class => "answer", :reference_identifier => "5")
    # Type Other
    q = Factory(:question, :reference_identifier => "CONTACT_PHONE1_TYPE_3_OTH", :data_export_identifier => "TRACING_INT.CONTACT_PHONE1_TYPE_3_OTH", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Specify", :response_class => "string")
    # Contact 3 phone
    q = Factory(:question, :reference_identifier => "CONTACT_PHONE_2_3", :data_export_identifier => "TRACING_INT.CONTACT_PHONE_2_3", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Phone Number", :response_class => "string")
    # Contact 3 phone type
    q = Factory(:question, :reference_identifier => "CONTACT_PHONE2_TYPE_3", :data_export_identifier => "TRACING_INT.CONTACT_PHONE2_TYPE_3", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Home", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "Work", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "Cell", :response_class => "answer", :reference_identifier => "3")
    a = Factory(:answer, :question_id => q.id, :text => "Friend/Relative", :response_class => "answer", :reference_identifier => "4")
    a = Factory(:answer, :question_id => q.id, :text => "Other", :response_class => "answer", :reference_identifier => "5")
    # Type Other
    q = Factory(:question, :reference_identifier => "CONTACT_PHONE2_TYPE_3_OTH", :data_export_identifier => "TRACING_INT.CONTACT_PHONE2_TYPE_3_OTH", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Specify", :response_class => "string")

    survey
  end

  def create_pregnancy_visit_1_survey_with_person_operational_data
    survey = Factory(:survey, :title => "INS_QUE_PregVisit1_INT_EHPBHI_P2_V2.0", :access_code => "ins-que-pregvisit1-int-ehpbhi-p2-v2-0_test")
    survey_section = Factory(:survey_section, :survey_id => survey.id)
    # First name
    q = Factory(:question, :reference_identifier => "R_FNAME", :data_export_identifier => "PREG_VISIT_1_2.R_FNAME", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "First name", :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")
    # Last name
    q = Factory(:question, :reference_identifier => "R_LNAME", :data_export_identifier => "PREG_VISIT_1_2.R_LNAME", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Last name", :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")
    # Date of Birth
    q = Factory(:question, :reference_identifier => "PERSON_DOB", :data_export_identifier => "PREG_VISIT_1_2.PERSON_DOB", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Date of Birth", :response_class => "date")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")
    # Age Eligible
    q = Factory(:question, :reference_identifier => "AGE_ELIG", :data_export_identifier => "PREG_VISIT_1_2.AGE_ELIG", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Age Eligible", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "Ineligible - too young", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "Ineligible - too old", :response_class => "answer", :reference_identifier => "3")

    # Multiple Gestation
    q = Factory(:question, :reference_identifier => "MULTIPLE_GESTATION", :data_export_identifier => "PREG_VISIT_1_2.MULTIPLE_GESTATION", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Singleton", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "Twins", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "Triplets or higher", :response_class => "answer", :reference_identifier => "3")

    survey
  end

  def create_pregnancy_visit_1_survey_with_contact_operational_data
    survey = Factory(:survey, :title => "INS_QUE_PregVisit1_INT_EHPBHI_P2_V2.0", :access_code => "ins-que-pregvisit1-int-ehpbhi-p2-v2-0_test")
    survey_section = Factory(:survey_section, :survey_id => survey.id)

    # Contact 1 First Name
    q = Factory(:question, :reference_identifier => "CONTACT_FNAME_1", :data_export_identifier => "PREG_VISIT_1_2.CONTACT_FNAME_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "First Name", :response_class => "string")
    # Contact 1 Last Name
    q = Factory(:question, :reference_identifier => "CONTACT_LNAME_1", :data_export_identifier => "PREG_VISIT_1_2.CONTACT_LNAME_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Last Name", :response_class => "string")
    # Contact 1 Relationship Code
    q = Factory(:question, :reference_identifier => "CONTACT_RELATE_1", :data_export_identifier => "PREG_VISIT_1_2.CONTACT_RELATE_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "MOTHER/FATHER", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "BROTHER/SISTER", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "AUNT/UNCLE", :response_class => "answer", :reference_identifier => "3")
    a = Factory(:answer, :question_id => q.id, :text => "GRANDPARENT", :response_class => "answer", :reference_identifier => "4")
    a = Factory(:answer, :question_id => q.id, :text => "NEIGHBOR", :response_class => "answer", :reference_identifier => "5")
    a = Factory(:answer, :question_id => q.id, :text => "FRIEND", :response_class => "answer", :reference_identifier => "6")
    a = Factory(:answer, :question_id => q.id, :text => "OTHER", :response_class => "answer", :reference_identifier => "neg_5")
    # Contact 1 Relationship Other
    q = Factory(:question, :reference_identifier => "CONTACT_RELATE1_OTH", :data_export_identifier => "PREG_VISIT_1_2.CONTACT_RELATE1_OTH", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Specify", :response_class => "string")
    # Contact 1 Address One
    q = Factory(:question, :reference_identifier => "C_ADDR_1_1", :data_export_identifier => "PREG_VISIT_1_2.C_ADDR_1_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address 1", :response_class => "string")
    # Contact 1 Address Two
    q = Factory(:question, :reference_identifier => "C_ADDR_2_1", :data_export_identifier => "PREG_VISIT_1_2.C_ADDR_2_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address 2", :response_class => "string")
    # Contact 1 Unit
    q = Factory(:question, :reference_identifier => "C_UNIT_1", :data_export_identifier => "PREG_VISIT_1_2.C_UNIT_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Unit", :response_class => "string")
    # Contact 1 City
    q = Factory(:question, :reference_identifier => "C_CITY_1", :data_export_identifier => "PREG_VISIT_1_2.C_CITY_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "City", :response_class => "string")
    # Contact 1 State
    q = Factory(:question, :reference_identifier => "C_STATE_1", :data_export_identifier => "PREG_VISIT_1_2.C_STATE_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "IL", :response_class => "answer", :reference_identifier => "14")
    a = Factory(:answer, :question_id => q.id, :text => "MI", :response_class => "answer", :reference_identifier => "23")
    # Contact 1 Zip
    q = Factory(:question, :reference_identifier => "C_ZIP_1", :data_export_identifier => "PREG_VISIT_1_2.C_ZIP_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Zip", :response_class => "string")
    # Contact 1 plus 4
    q = Factory(:question, :reference_identifier => "C_ZIP4_1", :data_export_identifier => "PREG_VISIT_1_2.C_ZIP4_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "plus 4", :response_class => "string")
    # Contact 1 phone
    q = Factory(:question, :reference_identifier => "CONTACT_PHONE_1", :data_export_identifier => "PREG_VISIT_1_2.CONTACT_PHONE_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Phone Number", :response_class => "string")

    # Contact 2 First Name
    q = Factory(:question, :reference_identifier => "CONTACT_FNAME_2", :data_export_identifier => "PREG_VISIT_1_2.CONTACT_FNAME_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "First Name", :response_class => "string")
    # Contact 2 Last Name
    q = Factory(:question, :reference_identifier => "CONTACT_LNAME_2", :data_export_identifier => "PREG_VISIT_1_2.CONTACT_LNAME_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Last Name", :response_class => "string")
    # Contact 2 Relationship Code
    q = Factory(:question, :reference_identifier => "CONTACT_RELATE_2", :data_export_identifier => "PREG_VISIT_1_2.CONTACT_RELATE_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "MOTHER/FATHER", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "BROTHER/SISTER", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "AUNT/UNCLE", :response_class => "answer", :reference_identifier => "3")
    a = Factory(:answer, :question_id => q.id, :text => "GRANDPARENT", :response_class => "answer", :reference_identifier => "4")
    a = Factory(:answer, :question_id => q.id, :text => "NEIGHBOR", :response_class => "answer", :reference_identifier => "5")
    a = Factory(:answer, :question_id => q.id, :text => "FRIEND", :response_class => "answer", :reference_identifier => "6")
    a = Factory(:answer, :question_id => q.id, :text => "OTHER", :response_class => "answer", :reference_identifier => "neg_5")
    # Contact 2 Relationship Other
    q = Factory(:question, :reference_identifier => "CONTACT_RELATE2_OTH", :data_export_identifier => "PREG_VISIT_1_2.CONTACT_RELATE2_OTH", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Specify", :response_class => "string")
    # Contact 2 Address One
    q = Factory(:question, :reference_identifier => "C_ADDR_1_2", :data_export_identifier => "PREG_VISIT_1_2.C_ADDR_1_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address 1", :response_class => "string")
    # Contact 2 Address Two
    q = Factory(:question, :reference_identifier => "C_ADDR_2_2", :data_export_identifier => "PREG_VISIT_1_2.C_ADDR_2_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address 2", :response_class => "string")
    # Contact 2 Unit
    q = Factory(:question, :reference_identifier => "C_UNIT_2", :data_export_identifier => "PREG_VISIT_1_2.C_UNIT_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Unit", :response_class => "string")
    # Contact 2 City
    q = Factory(:question, :reference_identifier => "C_CITY_2", :data_export_identifier => "PREG_VISIT_1_2.C_CITY_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "City", :response_class => "string")
    # Contact 2 State
    q = Factory(:question, :reference_identifier => "C_STATE_2", :data_export_identifier => "PREG_VISIT_1_2.C_STATE_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "IL", :response_class => "answer", :reference_identifier => "14")
    a = Factory(:answer, :question_id => q.id, :text => "MI", :response_class => "answer", :reference_identifier => "23")
    # Contact 2 Zip
    q = Factory(:question, :reference_identifier => "C_ZIP_2", :data_export_identifier => "PREG_VISIT_1_2.C_ZIP_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Zip", :response_class => "string")
    # Contact 2 plus 4
    q = Factory(:question, :reference_identifier => "C_ZIP4_2", :data_export_identifier => "PREG_VISIT_1_2.C_ZIP4_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "plus 4", :response_class => "string")
    # Contact 2 phone
    q = Factory(:question, :reference_identifier => "CONTACT_PHONE_2", :data_export_identifier => "PREG_VISIT_1_2.CONTACT_PHONE_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Phone Number", :response_class => "string")
    survey
  end

  def create_pregnancy_visit_1_survey_with_telephone_operational_data
    survey = Factory(:survey, :title => "INS_QUE_PregVisit1_INT_EHPBHI_P2_V2.0", :access_code => "ins-que-pregvisit1-int-ehpbhi-p2-v2-0_test")
    survey_section = Factory(:survey_section, :survey_id => survey.id)

    # Cell Phone
    q = Factory(:question, :reference_identifier => "CELL_PHONE", :data_export_identifier => "PREG_VISIT_1_2.CELL_PHONE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Phone Number", :response_class => "string")
    # Can call cell?
    q = Factory(:question, :reference_identifier => "CELL_PHONE_2", :data_export_identifier => "PREG_VISIT_1_2.CELL_PHONE_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Yes", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "No", :response_class => "answer", :reference_identifier => "2")
    # Can text?
    q = Factory(:question, :reference_identifier => "CELL_PHONE_4", :data_export_identifier => "PREG_VISIT_1_2.CELL_PHONE_4", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Yes", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "No", :response_class => "answer", :reference_identifier => "2")

    survey
  end

  def create_pregnancy_visit_1_survey_with_email_operational_data
    survey = Factory(:survey, :title => "INS_QUE_PregVisit1_INT_EHPBHI_P2_V2.0", :access_code => "ins-que-pregvisit1-int-ehpbhi-p2-v2-0_test")
    survey_section = Factory(:survey_section, :survey_id => survey.id)

    # Email
    q = Factory(:question, :reference_identifier => "EMAIL", :data_export_identifier => "PREG_VISIT_1_2.EMAIL", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Email", :response_class => "string")

    survey
  end

  def create_pregnancy_visit_1_saq_with_father_data
    survey = Factory(:survey, :title => "INS_QUE_PregVisit1_SAQ_EHPBHI_P2_V2.0", :access_code => "ins-que-pregvisit1-saq-ehpbhi-p2-v2-0_test")
    survey_section = Factory(:survey_section, :survey_id => survey.id)

    # Father Name
    q = Factory(:question, :reference_identifier => "FATHER_NAME", :data_export_identifier => "PREG_VISIT_1_SAQ_2.FATHER_NAME", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Father Name", :response_class => "string")

    survey
  end

  def create_pregnancy_visit_survey_with_birth_address_operational_data
    survey = Factory(:survey, :title => "INS_QUE_PregVisit1_INT_EHPBHI_P2_V2.0", :access_code => "ins-que-pregvisit1-int-ehpbhi-p2-v2-0_test")
    survey_section = Factory(:survey_section, :survey_id => survey.id)

    # Address One
    q = Factory(:question, :reference_identifier => "B_ADDR_1", :data_export_identifier => "PREG_VISIT_1_2.B_ADDR_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address 1", :response_class => "string")
    # Address Two
    q = Factory(:question, :reference_identifier => "B_ADDR_2", :data_export_identifier => "PREG_VISIT_1_2.B_ADDR_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address 2", :response_class => "string")
    # Unit
    q = Factory(:question, :reference_identifier => "B_UNIT", :data_export_identifier => "PREG_VISIT_1_2.B_UNIT", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Unit", :response_class => "string")
    # City
    q = Factory(:question, :reference_identifier => "B_CITY", :data_export_identifier => "PREG_VISIT_1_2.B_CITY", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "City", :response_class => "string")
    # State
    q = Factory(:question, :reference_identifier => "B_STATE", :data_export_identifier => "PREG_VISIT_1_2.B_STATE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "IL", :response_class => "answer", :reference_identifier => "14")
    a = Factory(:answer, :question_id => q.id, :text => "MI", :response_class => "answer", :reference_identifier => "23")
    # Zip
    q = Factory(:question, :reference_identifier => "B_ZIP", :data_export_identifier => "PREG_VISIT_1_2.B_ZIPCODE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Zip", :response_class => "string")

    survey
  end

  def create_pregnancy_visit_1_saq_survey_with_father_operational_data
    survey = Factory(:survey, :title => "INS_QUE_PregVisit1_SAQ_EHPBHI_P2_V2.0", :access_code => "ins-que-pregvisit1-saq-ehpbhi-p2-v2-0_test")
    survey_section = Factory(:survey_section, :survey_id => survey.id)
    # Father Name
    q = Factory(:question, :reference_identifier => "FATHER_NAME", :data_export_identifier => "PREG_VISIT_1_SAQ_2.FATHER_NAME", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Father Name", :response_class => "string")
    # Father Name
    q = Factory(:question, :reference_identifier => "FATHER_AGE", :data_export_identifier => "PREG_VISIT_1_SAQ_2.FATHER_AGE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Father Name", :response_class => "integer")
    # Address One
    q = Factory(:question, :reference_identifier => "F_ADDR_1", :data_export_identifier => "PREG_VISIT_1_SAQ_2.F_ADDR_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address 1", :response_class => "string")
    # Address Two
    q = Factory(:question, :reference_identifier => "F_ADDR_2", :data_export_identifier => "PREG_VISIT_1_SAQ_2.F_ADDR_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address 2", :response_class => "string")
    # Unit
    q = Factory(:question, :reference_identifier => "F_UNIT", :data_export_identifier => "PREG_VISIT_1_SAQ_2.F_UNIT", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Unit", :response_class => "string")
    # City
    q = Factory(:question, :reference_identifier => "F_CITY", :data_export_identifier => "PREG_VISIT_1_SAQ_2.F_CITY", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "City", :response_class => "string")
    # State
    q = Factory(:question, :reference_identifier => "F_STATE", :data_export_identifier => "PREG_VISIT_1_SAQ_2.F_STATE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "IL", :response_class => "answer", :reference_identifier => "14")
    a = Factory(:answer, :question_id => q.id, :text => "MI", :response_class => "answer", :reference_identifier => "23")
    # Zip
    q = Factory(:question, :reference_identifier => "F_ZIPCODE", :data_export_identifier => "PREG_VISIT_1_SAQ_2.F_ZIPCODE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Zip", :response_class => "string")
    # Zip
    q = Factory(:question, :reference_identifier => "F_ZIP4", :data_export_identifier => "PREG_VISIT_1_SAQ_2.F_ZIP4", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Zip", :response_class => "string")
    # Phone
    q = Factory(:question, :reference_identifier => "F_PHONE", :data_export_identifier => "PREG_VISIT_1_SAQ_2.F_PHONE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Phone Number", :response_class => "string")
    survey
  end

  def create_birth_survey_with_child_operational_data
    survey = Factory(:survey, :title => "INS_QUE_Birth_INT_EHPBHI_P2_V2.0", :access_code => "ins_que_birth_int_ehpbhi_p2_v2_0_test")
    survey_section = Factory(:survey_section, :survey_id => survey.id)
    # First Name
    q = Factory(:question, :reference_identifier => "BABY_FNAME", :data_export_identifier => "BIRTH_VISIT_BABY_NAME_2.BABY_FNAME", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "First Name", :response_class => "string")
    # First Name
    q = Factory(:question, :reference_identifier => "BABY_MNAME", :data_export_identifier => "BIRTH_VISIT_BABY_NAME_2.BABY_MNAME", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Middle Name", :response_class => "string")
    # Last Name
    q = Factory(:question, :reference_identifier => "BABY_LNAME", :data_export_identifier => "BIRTH_VISIT_BABY_NAME_2.BABY_LNAME", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Last Name", :response_class => "string")

    # Last Name
    q = Factory(:question, :reference_identifier => "BABY_SEX", :data_export_identifier => "BIRTH_VISIT_BABY_NAME_2.BABY_SEX", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Male", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "Female", :response_class => "answer", :reference_identifier => "2")

    # Multiple
    q = Factory(:question, :reference_identifier => "MULTIPLE", :data_export_identifier => "BIRTH_VISIT_2.MULTIPLE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Yes", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "No", :response_class => "answer", :reference_identifier => "2")

    survey
  end

  def create_lo_i_birth_survey
    survey = Factory(:survey, :title => "INS_QUE_Birth_INT_LI_P2_V1.0", :access_code => "ins-que-birth-int-li-p2-v2-0")
    survey_section = Factory(:survey_section, :survey_id => survey.id)
    survey
  end

  def create_birth_survey_with_tracing_operational_data
    survey = Factory(:survey, :title => "INS_QUE_Birth_INT_EHPBHI_P2_V2.0", :access_code => "ins-que-birth-int-ehpbhi-p2-v2-0")
    survey_section = Factory(:survey_section, :survey_id => survey.id)
    # First name
    q = Factory(:question, :reference_identifier => "R_FNAME", :data_export_identifier => "BIRTH_VISIT_2.R_FNAME", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "First name", :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")
    # Last name
    q = Factory(:question, :reference_identifier => "R_LNAME", :data_export_identifier => "BIRTH_VISIT_2.R_LNAME", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Last name", :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")

    # Phone Number
    q = Factory(:question, :reference_identifier => "PHONE_NBR", :data_export_identifier => "BIRTH_VISIT_2.PHONE_NBR", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Phone Number", :response_class => "string")
    # Phone Number other
    q = Factory(:question, :reference_identifier => "PHONE_NBR_OTH", :data_export_identifier => "BIRTH_VISIT_2.PHONE_NBR_OTH", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Phone Number", :response_class => "string")
    # Type
    q = Factory(:question, :reference_identifier => "PHONE_TYPE", :data_export_identifier => "BIRTH_VISIT_2.PHONE_TYPE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Home", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "Work", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "Cell", :response_class => "answer", :reference_identifier => "3")
    a = Factory(:answer, :question_id => q.id, :text => "Friend/Relative", :response_class => "answer", :reference_identifier => "4")
    a = Factory(:answer, :question_id => q.id, :text => "Other", :response_class => "answer", :reference_identifier => "5")
    # Type Other
    q = Factory(:question, :reference_identifier => "PHONE_TYPE_OTH", :data_export_identifier => "BIRTH_VISIT_2.PHONE_TYPE_OTH", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Specify", :response_class => "string")
    # Home Phone
    q = Factory(:question, :reference_identifier => "HOME_PHONE", :data_export_identifier => "BIRTH_VISIT_2.HOME_PHONE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Phone Number", :response_class => "string")
    # Cell Phone
    q = Factory(:question, :reference_identifier => "CELL_PHONE", :data_export_identifier => "BIRTH_VISIT_2.CELL_PHONE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Phone Number", :response_class => "string")
    # Can call cell?
    q = Factory(:question, :reference_identifier => "CELL_PHONE_2", :data_export_identifier => "BIRTH_VISIT_2.CELL_PHONE_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Yes", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "No", :response_class => "answer", :reference_identifier => "2")
    # Can text?
    q = Factory(:question, :reference_identifier => "CELL_PHONE_4", :data_export_identifier => "BIRTH_VISIT_2.CELL_PHONE_4", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Yes", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "No", :response_class => "answer", :reference_identifier => "2")

    # Address One
    q = Factory(:question, :reference_identifier => "MAIL_ADDRESS_1", :data_export_identifier => "BIRTH_VISIT_2.MAIL_ADDRESS1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address 1", :response_class => "string")
    # Address Two
    q = Factory(:question, :reference_identifier => "MAIL_ADDRESS_2", :data_export_identifier => "BIRTH_VISIT_2.MAIL_ADDRESS2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address 2", :response_class => "string")
    # Unit
    q = Factory(:question, :reference_identifier => "MAIL_UNIT", :data_export_identifier => "BIRTH_VISIT_2.MAIL_UNIT", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Unit", :response_class => "string")
    # City
    q = Factory(:question, :reference_identifier => "MAIL_CITY", :data_export_identifier => "BIRTH_VISIT_2.MAIL_CITY", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "City", :response_class => "string")
    # State
    q = Factory(:question, :reference_identifier => "MAIL_STATE", :data_export_identifier => "BIRTH_VISIT_2.MAIL_STATE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "IL", :response_class => "answer", :reference_identifier => "14")
    a = Factory(:answer, :question_id => q.id, :text => "MI", :response_class => "answer", :reference_identifier => "23")
    # Zip
    q = Factory(:question, :reference_identifier => "MAIL_ZIP", :data_export_identifier => "BIRTH_VISIT_2.MAIL_ZIP", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Zip", :response_class => "string")
    # plus 4
    q = Factory(:question, :reference_identifier => "MAIL_ZIP4", :data_export_identifier => "BIRTH_VISIT_2.MAIL_ZIP4", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "plus 4", :response_class => "string")

    # Email
    q = Factory(:question, :reference_identifier => "EMAIL", :data_export_identifier => "BIRTH_VISIT_2.EMAIL", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Email", :response_class => "string")
    # Type
    q = Factory(:question, :reference_identifier => "EMAIL_TYPE", :data_export_identifier => "BIRTH_VISIT_2.EMAIL_TYPE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Personal", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "Work", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "Family/Shared", :response_class => "answer", :reference_identifier => "3")

    survey
  end

  def create_three_month_mother_int_child_detail_survey_with_child_name_operational_data
    survey = Factory(:survey, :title => "INS_QUE_3MMother_INT_EHPBHI_P2_V1.1_CHILD_DETAIL", :access_code => "ins-que-3mmother-int-ehpbhi-p2-v1-1-child-detail")
    survey_section = Factory(:survey_section, :survey_id => survey.id)

    # First name
    q = Factory(:question, :reference_identifier => "C_FNAME", :data_export_identifier => "THREE_MTH_MOTHER_CHILD_DETAIL.C_FNAME", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "First name", :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")
    # Last name
    q = Factory(:question, :reference_identifier => "C_LNAME", :data_export_identifier => "THREE_MTH_MOTHER_CHILD_DETAIL.C_LNAME", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Last name", :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")

    survey
  end

  def create_three_month_mother_int_child_detail_survey_with_date_of_birth_operational_data
    survey = Factory(:survey, :title => "INS_QUE_3MMother_INT_EHPBHI_P2_V1.1_CHILD_DETAIL", :access_code => "ins-que-3mmother-int-ehpbhi-p2-v1-1-child-detail")
    survey_section = Factory(:survey_section, :survey_id => survey.id)

    # Date of Birth
    q = Factory(:question, :reference_identifier => "CHILD_DOB", :data_export_identifier => "THREE_MTH_MOTHER_CHILD_DETAIL.CHILD_DOB", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Date of Birth", :response_class => "date")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")

    survey
  end

  def create_six_month_mother_int_mother_detail_survey_with_operational_data
    survey = Factory(:survey, :title => "INS_QUE_6MMother_INT_EHPBHI_P2_V11_SIX_MTH_MOTHER_DETAIL", :access_code => "ins_que_6mmother_int_ehpbhi_p2_v11_six_mth_mother_detail")
    survey_section = Factory(:survey_section, :survey_id => survey.id)

    # First name
    q = Factory(:question, :reference_identifier => "C_FNAME", :data_export_identifier => "SIX_MTH_MOTHER_DETAIL.C_FNAME", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "First name", :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")

    # Last name
    q = Factory(:question, :reference_identifier => "C_LNAME", :data_export_identifier => "SIX_MTH_MOTHER_DETAIL.C_LNAME", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Last name", :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")

    # Date of Birth
    q = Factory(:question, :reference_identifier => "CHILD_DOB", :data_export_identifier => "SIX_MTH_MOTHER_DETAIL.CHILD_DOB", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Date of Birth", :response_class => "date")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")

    # Email
    q = Factory(:question, :reference_identifier => "EMAIL", :data_export_identifier => "SIX_MTH_MOTHER.EMAIL", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Email", :response_class => "string")

    # Cellular Phone : Has info changed?
    q = Factory(:question, :reference_identifier => "COMM_CELL", :data_export_identifier => "SIX_MTH_MOTHER.COMM_CELL", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Yes", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "No", :response_class => "answer", :reference_identifier => "2")

    # Cellular Phone : Do you have a cell phone?
    q = Factory(:question, :reference_identifier => "CELL_PHONE_1", :data_export_identifier => "SIX_MTH_MOTHER.CELL_PHONE_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Yes", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "No", :response_class => "answer", :reference_identifier => "2")

    # Cellular Phone : May we call your primary cell phone?
    q = Factory(:question, :reference_identifier => "CELL_PHONE_2", :data_export_identifier => "SIX_MTH_MOTHER.CELL_PHONE_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Yes", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "No", :response_class => "answer", :reference_identifier => "2")

    # Cellular Phone : May we text you?
    q = Factory(:question, :reference_identifier => "CELL_PHONE_4", :data_export_identifier => "SIX_MTH_MOTHER.CELL_PHONE_4", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Yes", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "No", :response_class => "answer", :reference_identifier => "2")

    # Cellular Phone : Phone number
    q = Factory(:question, :reference_identifier => "CELL_PHONE", :data_export_identifier => "SIX_MTH_MOTHER.CELL_PHONE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Phone Number", :response_class => "string")

    # Contact 1 First Name
    q = Factory(:question, :reference_identifier => "CONTACT_FNAME_1", :data_export_identifier => "SIX_MTH_MOTHER.CONTACT_FNAME_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "First Name", :response_class => "string")

    # Contact 1 Last Name
    q = Factory(:question, :reference_identifier => "CONTACT_LNAME_1", :data_export_identifier => "SIX_MTH_MOTHER.CONTACT_LNAME_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Last Name", :response_class => "string")

    # Contact 1 Relationship Code
    q = Factory(:question, :reference_identifier => "CONTACT_RELATE_1", :data_export_identifier => "SIX_MTH_MOTHER.CONTACT_RELATE_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "MOTHER/FATHER", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "BROTHER/SISTER", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "AUNT/UNCLE", :response_class => "answer", :reference_identifier => "3")
    a = Factory(:answer, :question_id => q.id, :text => "GRANDPARENT", :response_class => "answer", :reference_identifier => "4")
    a = Factory(:answer, :question_id => q.id, :text => "NEIGHBOR", :response_class => "answer", :reference_identifier => "5")
    a = Factory(:answer, :question_id => q.id, :text => "FRIEND", :response_class => "answer", :reference_identifier => "6")
    a = Factory(:answer, :question_id => q.id, :text => "OTHER", :response_class => "answer", :reference_identifier => "neg_5")

    # Contact 1 Relationship Other
    q = Factory(:question, :reference_identifier => "CONTACT_RELATE1_OTH", :data_export_identifier => "SIX_MTH_MOTHER.CONTACT_RELATE1_OTH", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Specify", :response_class => "string")

    # Contact 1 Address One
    q = Factory(:question, :reference_identifier => "C_ADDR_1_1", :data_export_identifier => "SIX_MTH_MOTHER.C_ADDR_1_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address 1", :response_class => "string")

    # Contact 1 Address Two
    q = Factory(:question, :reference_identifier => "C_ADDR_2_1", :data_export_identifier => "SIX_MTH_MOTHER.C_ADDR_2_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address 2", :response_class => "string")

    # Contact 1 Unit
    q = Factory(:question, :reference_identifier => "C_UNIT_1", :data_export_identifier => "SIX_MTH_MOTHER.C_UNIT_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Unit", :response_class => "string")

    # Contact 1 City
    q = Factory(:question, :reference_identifier => "C_CITY_1", :data_export_identifier => "SIX_MTH_MOTHER.C_CITY_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "City", :response_class => "string")

    # Contact 1 State
    q = Factory(:question, :reference_identifier => "C_STATE_1", :data_export_identifier => "SIX_MTH_MOTHER.C_STATE_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "IL", :response_class => "answer", :reference_identifier => "14")
    a = Factory(:answer, :question_id => q.id, :text => "MI", :response_class => "answer", :reference_identifier => "23")

    # Contact 1 Zip
    q = Factory(:question, :reference_identifier => "C_ZIP_1", :data_export_identifier => "SIX_MTH_MOTHER.C_ZIP_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Zip", :response_class => "string")

    # Contact 1 plus 4
    q = Factory(:question, :reference_identifier => "C_ZIP4_1", :data_export_identifier => "SIX_MTH_MOTHER.C_ZIP4_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "plus 4", :response_class => "string")

    # Contact 1 phone
    q = Factory(:question, :reference_identifier => "CONTACT_PHONE_1", :data_export_identifier => "SIX_MTH_MOTHER.CONTACT_PHONE_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Phone Number", :response_class => "string")

    # Contact 2 First Name
    q = Factory(:question, :reference_identifier => "CONTACT_FNAME_2", :data_export_identifier => "SIX_MTH_MOTHER.CONTACT_FNAME_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "First Name", :response_class => "string")

    # Contact 2 Last Name
    q = Factory(:question, :reference_identifier => "CONTACT_LNAME_2", :data_export_identifier => "SIX_MTH_MOTHER.CONTACT_LNAME_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Last Name", :response_class => "string")

    # Contact 2 Relationship Code
    q = Factory(:question, :reference_identifier => "CONTACT_RELATE_2", :data_export_identifier => "SIX_MTH_MOTHER.CONTACT_RELATE_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "MOTHER/FATHER", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "BROTHER/SISTER", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "AUNT/UNCLE", :response_class => "answer", :reference_identifier => "3")
    a = Factory(:answer, :question_id => q.id, :text => "GRANDPARENT", :response_class => "answer", :reference_identifier => "4")
    a = Factory(:answer, :question_id => q.id, :text => "NEIGHBOR", :response_class => "answer", :reference_identifier => "5")
    a = Factory(:answer, :question_id => q.id, :text => "FRIEND", :response_class => "answer", :reference_identifier => "6")
    a = Factory(:answer, :question_id => q.id, :text => "OTHER", :response_class => "answer", :reference_identifier => "neg_5")

    # Contact 2 Relationship Other
    q = Factory(:question, :reference_identifier => "CONTACT_RELATE2_OTH", :data_export_identifier => "SIX_MTH_MOTHER.CONTACT_RELATE2_OTH", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Specify", :response_class => "string")

    # Contact 2 Address One
    q = Factory(:question, :reference_identifier => "C_ADDR_1_2", :data_export_identifier => "SIX_MTH_MOTHER.C_ADDR_1_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address 1", :response_class => "string")

    # Contact 2 Address Two
    q = Factory(:question, :reference_identifier => "C_ADDR_2_2", :data_export_identifier => "SIX_MTH_MOTHER.C_ADDR_2_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address 2", :response_class => "string")

    # Contact 2 Unit
    q = Factory(:question, :reference_identifier => "C_UNIT_2", :data_export_identifier => "SIX_MTH_MOTHER.C_UNIT_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Unit", :response_class => "string")

    # Contact 2 City
    q = Factory(:question, :reference_identifier => "C_CITY_2", :data_export_identifier => "SIX_MTH_MOTHER.C_CITY_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "City", :response_class => "string")

    # Contact 2 State
    q = Factory(:question, :reference_identifier => "C_STATE_2", :data_export_identifier => "SIX_MTH_MOTHER.C_STATE_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "IL", :response_class => "answer", :reference_identifier => "14")
    a = Factory(:answer, :question_id => q.id, :text => "MI", :response_class => "answer", :reference_identifier => "23")

    # Contact 2 Zip
    q = Factory(:question, :reference_identifier => "C_ZIP_2", :data_export_identifier => "SIX_MTH_MOTHER.C_ZIP_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Zip", :response_class => "string")

    # Contact 2 plus 4
    q = Factory(:question, :reference_identifier => "C_ZIP4_2", :data_export_identifier => "SIX_MTH_MOTHER.C_ZIP4_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "plus 4", :response_class => "string")

    # Contact 2 phone
    q = Factory(:question, :reference_identifier => "CONTACT_PHONE_2", :data_export_identifier => "SIX_MTH_MOTHER.CONTACT_PHONE_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Phone Number", :response_class => "string")

    survey
  end

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

end
