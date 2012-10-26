# -*- coding: utf-8 -*-

module PbsEligibilityScreener

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

  def create_pbs_eligibility_screener_survey_with_email_operational_data
    survey = Factory(:survey, :title => "INS_QUE_PBSamplingScreen_INT_PBS_M3.0_V1.0", :access_code => "ins-que-pbsamplingscreen-int-pbs-m3-0-v1-0")
    survey_section = Factory(:survey_section, :survey_id => survey.id)
    # Email
    q = Factory(:question, :reference_identifier => "R_EMAIL", :data_export_identifier => "PBS_ELIG_SCREENER.R_EMAIL", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Email", :response_class => "string")

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

end