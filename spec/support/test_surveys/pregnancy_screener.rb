# -*- coding: utf-8 -*-

module PregnancyScreener

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

  def create_pregnancy_screener_survey_with_race_operational_data
    survey = Factory(:survey, :title => "INS_QUE_PregScreen_INT_HILI_M2.1_V2.1", :access_code => "ins-que-pregscreen-int-hili-m2-1-v2-1")
    survey_section = Factory(:survey_section, :survey_id => survey.id)

    # Race One
    q = Factory(:question, :reference_identifier => "RACE", :data_export_identifier => "PREG_SCREEN_HI_RACE_2.RACE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Black or African American", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "Other", :response_class => "answer", :reference_identifier => "neg_5")
    a = Factory(:answer, :question_id => q.id, :text => "Asian", :response_class => "answer", :reference_identifier => "4")

    # Race One Other
    q = Factory(:question, :reference_identifier => "RACE_OTH", :data_export_identifier => "PREG_SCREEN_HI_RACE_2.RACE_OTH", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :response_class => 'string', :text => 'SPECIFY')

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
    a = Factory(:answer, :question_id => q.id, :text => "Don't Know", :response_class => "answer", :reference_identifier => "neg_2")
    # Zip
    q = Factory(:question, :reference_identifier => "ZIP", :data_export_identifier => "PREG_SCREEN_HI_2.ZIP", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Zip", :response_class => "string")
    # plus 4
    q = Factory(:question, :reference_identifier => "ZIP4", :data_export_identifier => "PREG_SCREEN_HI_2.ZIP4", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "plus 4", :response_class => "string")

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

end
