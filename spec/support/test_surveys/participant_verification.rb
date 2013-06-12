# -*- coding: utf-8 -*-

module ParticipantVerification

  def create_participant_verification_survey
    survey = Factory(:survey, :title => "INS_QUE_ParticipantVerif_DCI_EHPBHILIPBS_M3.0_V1.0", :access_code => "ins-que-participantverif-dci-ehpbhilipbs-m3-0-v1-0")
    survey_section = Factory(:survey_section, :survey_id => survey.id)

    # prepopulated mode of contact
    q = Factory(:question, :reference_identifier => "prepopulated_mode_of_contact", :data_export_identifier => "prepopulated_mode_of_contact", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "CAPI", :response_class => "answer", :reference_identifier => "capi")
    a = Factory(:answer, :question_id => q.id, :text => "CATI", :response_class => "answer", :reference_identifier => "cati")
    a = Factory(:answer, :question_id => q.id, :text => "PAPI", :response_class => "answer", :reference_identifier => "papi")

    # First name
    q = Factory(:question, :reference_identifier => "R_FNAME", :data_export_identifier => "PARTICIPANT_VERIF.R_FNAME", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "First name", :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")
    # Middle name
    q = Factory(:question, :reference_identifier => "R_MNAME", :data_export_identifier => "PARTICIPANT_VERIF.R_MNAME", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Middle name", :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")
    # Last name
    q = Factory(:question, :reference_identifier => "R_LNAME", :data_export_identifier => "PARTICIPANT_VERIF.R_LNAME", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Last name", :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")
    # Maiden name
    q = Factory(:question, :reference_identifier => "MAIDEN_NAME", :data_export_identifier => "PARTICIPANT_VERIF.MAIDEN_NAME", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Maiden name", :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")
    # Date of Birth
    q = Factory(:question, :reference_identifier => "PERSON_DOB", :data_export_identifier => "PARTICIPANT_VERIF.PERSON_DOB", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Date of Birth", :response_class => "date")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")

    # Child First Name
    q = Factory(:question, :reference_identifier => "C_FNAME", :data_export_identifier => "PARTICIPANT_VERIF_CHILD.C_FNAME", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "First Name", :response_class => "string")
    # Child Last Name
    q = Factory(:question, :reference_identifier => "C_LNAME", :data_export_identifier => "PARTICIPANT_VERIF_CHILD.C_LNAME", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Last Name", :response_class => "string")
    # Child Date of Birth
    q = Factory(:question, :reference_identifier => "CHILD_DOB", :data_export_identifier => "PARTICIPANT_VERIF_CHILD.CHILD_DOB", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Date of Birth", :response_class => "date")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")
    # Child Gender
    q = Factory(:question, :reference_identifier => "CHILD_SEX", :data_export_identifier => "PARTICIPANT_VERIF_CHILD.CHILD_SEX", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "MALE", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "FEMALE", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")

    # Address One
    q = Factory(:question, :reference_identifier => "C_ADDRESS_1", :data_export_identifier => "PARTICIPANT_VERIF.C_ADDRESS_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address 1", :response_class => "string")
    # Address Two
    q = Factory(:question, :reference_identifier => "C_ADDRESS_2", :data_export_identifier => "PARTICIPANT_VERIF.C_ADDRESS_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address 2", :response_class => "string")
    # City
    q = Factory(:question, :reference_identifier => "C_CITY", :data_export_identifier => "PARTICIPANT_VERIF.C_CITY", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "City", :response_class => "string")
    # State
    q = Factory(:question, :reference_identifier => "C_STATE", :data_export_identifier => "PARTICIPANT_VERIF.C_STATE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "IL", :response_class => "answer", :reference_identifier => "14")
    a = Factory(:answer, :question_id => q.id, :text => "MI", :response_class => "answer", :reference_identifier => "23")
    # Zip
    q = Factory(:question, :reference_identifier => "C_ZIP", :data_export_identifier => "PARTICIPANT_VERIF.C_ZIP", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Zip", :response_class => "string")
    # plus 4
    q = Factory(:question, :reference_identifier => "C_ZIP4", :data_export_identifier => "PARTICIPANT_VERIF.C_ZIP4", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "plus 4", :response_class => "string")

    # Address One
    q = Factory(:question, :reference_identifier => "S_ADDRESS_1", :data_export_identifier => "PARTICIPANT_VERIF.S_ADDRESS_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address 1", :response_class => "string")
    # Address Two
    q = Factory(:question, :reference_identifier => "S_ADDRESS_2", :data_export_identifier => "PARTICIPANT_VERIF.S_ADDRESS_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address 2", :response_class => "string")
    # City
    q = Factory(:question, :reference_identifier => "S_CITY", :data_export_identifier => "PARTICIPANT_VERIF.S_CITY", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "City", :response_class => "string")
    # State
    q = Factory(:question, :reference_identifier => "S_STATE", :data_export_identifier => "PARTICIPANT_VERIF.S_STATE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "IL", :response_class => "answer", :reference_identifier => "14")
    a = Factory(:answer, :question_id => q.id, :text => "MI", :response_class => "answer", :reference_identifier => "23")
    # Zip
    q = Factory(:question, :reference_identifier => "S_ZIP", :data_export_identifier => "PARTICIPANT_VERIF.S_ZIP", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Zip", :response_class => "string")
    # plus 4
    q = Factory(:question, :reference_identifier => "S_ZIP4", :data_export_identifier => "PARTICIPANT_VERIF.S_ZIP4", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "plus 4", :response_class => "string")

    # Phone Number
    q = Factory(:question, :reference_identifier => "PA_PHONE", :data_export_identifier => "PARTICIPANT_VERIF.PA_PHONE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Phone Number", :response_class => "string")

    # Phone Number
    q = Factory(:question, :reference_identifier => "SA_PHONE", :data_export_identifier => "PARTICIPANT_VERIF.SA_PHONE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Phone Number", :response_class => "string")

    survey
  end

  def create_participant_verification_part_one_survey_with_prepopulated_fields
    survey = Factory(:survey, :title => "INS_QUE_ParticipantVerif_DCI_EHPBHILIPBS_M3.0_V1.0_PART_ONE", :access_code => "ins-que-participantverif-dci-ehpbhilipbs-m3-0-v1-0-part-one")
    survey_section = Factory(:survey_section, :survey_id => survey.id)

    # prepopulated_is_pv1_or_pv2_or_father_for_participant_verification
    q = Factory(:question, :reference_identifier => "prepopulated_is_pv1_or_pv2_or_father_for_participant_verification", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE", :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE", :response_class => "answer", :reference_identifier => "false")

    # First name
    q = Factory(:question, :reference_identifier => "R_FNAME", :data_export_identifier => "PARTICIPANT_VERIF.R_FNAME", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "First name", :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")
    # Middle name
    q = Factory(:question, :reference_identifier => "R_MNAME", :data_export_identifier => "PARTICIPANT_VERIF.R_MNAME", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Middle name", :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")
    a = Factory(:answer, :question_id => q.id, :text => "PARENT/CAREGIVER HAS NO MIDDLE NAME", :response_class => "answer", :reference_identifier => "neg_7")
    # Last name
    q = Factory(:question, :reference_identifier => "R_LNAME", :data_export_identifier => "PARTICIPANT_VERIF.R_LNAME", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Last name", :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")

    # prepopulated_respondent_name_collected
    q = Factory(:question, :reference_identifier => "prepopulated_respondent_name_collected", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE", :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE", :response_class => "answer", :reference_identifier => "false")

    # prepopulated_should_show_maiden_name_and_nicknames
    q = Factory(:question, :reference_identifier => "prepopulated_should_show_maiden_name_and_nicknames", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE", :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE", :response_class => "answer", :reference_identifier => "false")

    # prepopulated_person_dob_previously_collected
    q = Factory(:question, :reference_identifier => "prepopulated_person_dob_previously_collected", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE", :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE", :response_class => "answer", :reference_identifier => "false")

    # Date of Birth
    q = Factory(:question, :reference_identifier => "PERSON_DOB", :data_export_identifier => "PARTICIPANT_VERIF.PERSON_DOB", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Date of Birth", :response_class => "date")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")

    # prepopulated_resp_guard_previously_collected
    q = Factory(:question, :reference_identifier => "prepopulated_resp_guard_previously_collected", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE", :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE", :response_class => "answer", :reference_identifier => "false")

    # RESP_GUARD
    q = Factory(:question, :reference_identifier => "RESP_GUARD", :data_export_identifier => "PARTICIPANT_VERIF.RESP_GUARD", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Yes", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "No", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")

    # prepopulated_should_show_resp_pcare
    q = Factory(:question, :reference_identifier => "prepopulated_should_show_resp_pcare", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE", :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE", :response_class => "answer", :reference_identifier => "false")

    # prepopulated_resp_pcare_equals_one_in_previous_survey
    q = Factory(:question, :reference_identifier => "prepopulated_resp_pcare_equals_one_in_previous_survey", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE", :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE", :response_class => "answer", :reference_identifier => "false")

    # RESP_PCARE
    q = Factory(:question, :reference_identifier => "RESP_PCARE", :data_export_identifier => "PARTICIPANT_VERIF.RESP_PCARE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Yes", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "No", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")

    # prepopulated_pcare_rel_previously_collected
    q = Factory(:question, :reference_identifier => "prepopulated_pcare_rel_previously_collected", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE", :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE", :response_class => "answer", :reference_identifier => "false")

    # PCARE_REL
    q = Factory(:question, :reference_identifier => "PCARE_REL", :data_export_identifier => "PARTICIPANT_VERIF.PCARE_REL", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "BIOLOGICAL (OR BIRTH) MOTHER", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "ADOPTIVE MOTHER", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")

    # prepopulated_ocare_child_previously_collected_and_equals_one
    q = Factory(:question, :reference_identifier => "prepopulated_ocare_child_previously_collected_and_equals_one", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE", :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE", :response_class => "answer", :reference_identifier => "false")

    # OCARE_CHILD
    q = Factory(:question, :reference_identifier => "OCARE_CHILD", :data_export_identifier => "PARTICIPANT_VERIF.OCARE_CHILD", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Yes", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "No", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")

    # prepopulated_ocare_child_equal_one_and_other_caregiver_name_previously_collected
    q = Factory(:question, :reference_identifier => "prepopulated_ocare_child_equal_one_and_other_caregiver_name_previously_collected", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE", :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE", :response_class => "answer", :reference_identifier => "false")

    # First name
    q = Factory(:question, :reference_identifier => "O_FNAME", :data_export_identifier => "PARTICIPANT_VERIF.O_FNAME", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "First name", :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")
    # Middle name
    q = Factory(:question, :reference_identifier => "O_MNAME", :data_export_identifier => "PARTICIPANT_VERIF.O_MNAME", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Middle name", :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")
    a = Factory(:answer, :question_id => q.id, :text => "NO MIDDLE NAME", :response_class => "answer", :reference_identifier => "neg_7")
    # Last name
    q = Factory(:question, :reference_identifier => "O_LNAME", :data_export_identifier => "PARTICIPANT_VERIF.O_LNAME", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Last name", :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")

    # prepopulated_ocare_rel_previously_collected
    q = Factory(:question, :reference_identifier => "prepopulated_ocare_rel_previously_collected", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE", :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE", :response_class => "answer", :reference_identifier => "false")

    # OCARE_REL
    q = Factory(:question, :reference_identifier => "OCARE_REL", :data_export_identifier => "PARTICIPANT_VERIF.OCARE_REL", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "BIOLOGICAL (OR BIRTH) MOTHER", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "ADOPTIVE MOTHER", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")

    # prepopulated_child_time_previously_collected
    q = Factory(:question, :reference_identifier => "prepopulated_child_time_previously_collected", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE", :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE", :response_class => "answer", :reference_identifier => "false")

    # CHILD_TIME
    q = Factory(:question, :reference_identifier => "CHILD_TIME", :data_export_identifier => "PARTICIPANT_VERIF.CHILD_TIME", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "FULL-TIME", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "SPLITS TIME", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")

    # prepopulated_child_primary_address_variables_previously_collected
    q = Factory(:question, :reference_identifier => "prepopulated_child_primary_address_variables_previously_collected", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE", :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE", :response_class => "answer", :reference_identifier => "false")

    # Address One
    q = Factory(:question, :reference_identifier => "C_ADDRESS_1", :data_export_identifier => "PARTICIPANT_VERIF.C_ADDRESS_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address 1", :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")

    # prepopulated_pa_phone_previously_collected
    q = Factory(:question, :reference_identifier => "prepopulated_pa_phone_previously_collected", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE", :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE", :response_class => "answer", :reference_identifier => "false")

    # PA_PHONE
    q = Factory(:question, :reference_identifier => "PA_PHONE", :data_export_identifier => "PARTICIPANT_VERIF.PA_PHONE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Phone", :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")

    # TODO: prepopulated_should_show_secondary_address_questions

    # prepopulated_child_secondary_address_variables_previously_collected
    q = Factory(:question, :reference_identifier => "prepopulated_child_secondary_address_variables_previously_collected", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE", :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE", :response_class => "answer", :reference_identifier => "false")

    # 2ndary Address One
    q = Factory(:question, :reference_identifier => "C_ADDRESS_1", :data_export_identifier => "PARTICIPANT_VERIF.S_ADDRESS_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address 1", :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")

    # prepopulated_sa_phone_previously_collected
    q = Factory(:question, :reference_identifier => "prepopulated_sa_phone_previously_collected", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE", :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE", :response_class => "answer", :reference_identifier => "false")

    # SA_PHONE
    q = Factory(:question, :reference_identifier => "SA_PHONE", :data_export_identifier => "PARTICIPANT_VERIF.SA_PHONE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Phone", :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")

    # prepopulated_resp_relationship_previously_collected
    q = Factory(:question, :reference_identifier => "prepopulated_resp_relationship_previously_collected", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE", :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE", :response_class => "answer", :reference_identifier => "false")

    # Respondent Relationship
    q = Factory(:question, :reference_identifier => "RESP_REL_NEW", :data_export_identifier => "PARTICIPANT_VERIF.RESP_REL_NEW", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "BIOLOGICAL (OR BIRTH) MOTHER", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "REFUSED", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "DON'T KNOW", :response_class => "answer", :reference_identifier => "neg_2")
    
    survey
  end

  def create_participant_verification_part_two_survey_with_prepopulated_fields
    survey = Factory(:survey, :title => "INS_QUE_ParticipantVerif_DCI_EHPBHILIPBS_M3.0_V1.0_PART_TWO",
                     :access_code => "ins-que-participantverif-dci-ehpbhilipbs-m3-0-v1-0-part-two")
    survey_section = Factory(:survey_section, :survey_id => survey.id)

    # prepopulated_should_show_child_name
    q = Factory(:question, :reference_identifier => "prepopulated_should_show_child_name", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE", :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE", :response_class => "answer", :reference_identifier => "false")

    # Child First Name
    q = Factory(:question, :reference_identifier => "C_FNAME", :data_export_identifier => "PARTICIPANT_VERIF_CHILD.C_FNAME", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "First Name", :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")
    # Child Last Name
    q = Factory(:question, :reference_identifier => "C_LNAME", :data_export_identifier => "PARTICIPANT_VERIF_CHILD.C_LNAME", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Last Name", :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")

    # prepopulated_should_show_child_dob
    q = Factory(:question, :reference_identifier => "prepopulated_should_show_child_dob", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE", :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE", :response_class => "answer", :reference_identifier => "false")

    # Child Date of Birth
    q = Factory(:question, :reference_identifier => "CHILD_DOB", :data_export_identifier => "PARTICIPANT_VERIF_CHILD.CHILD_DOB", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Date of Birth", :response_class => "date")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")

    # prepopulated_should_show_child_sex
    q = Factory(:question, :reference_identifier => "prepopulated_should_show_child_sex", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE", :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE", :response_class => "answer", :reference_identifier => "false")

    # Child Gender
    q = Factory(:question, :reference_identifier => "CHILD_SEX", :data_export_identifier => "PARTICIPANT_VERIF_CHILD.CHILD_SEX", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "MALE", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "FEMALE", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")

    # prepopulated_first_child
    q = Factory(:question, :reference_identifier => "prepopulated_first_child", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE", :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE", :response_class => "answer", :reference_identifier => "false")

    survey
  end

end
