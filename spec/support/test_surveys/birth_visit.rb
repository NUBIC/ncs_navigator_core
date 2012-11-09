# -*- coding: utf-8 -*-

module BirthVisit

  def create_birth_survey_with_child_operational_data
    survey = Factory(:survey, :title => "INS_QUE_Birth_INT_EHPBHI_P2_V2.0", :access_code => "ins_que_birth_int_ehpbhi_p2_v2_0_test")
    survey_section = Factory(:survey_section, :survey_id => survey.id)
    # First Name
    q = Factory(:question, :reference_identifier => "BABY_FNAME", :data_export_identifier => "BIRTH_VISIT_BABY_NAME_2.BABY_FNAME", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "First Name", :response_class => "string")
    # Middle Name
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

    # Multiple Num
    q = Factory(:question, :reference_identifier => "MULTIPLE_NUM", :data_export_identifier => "BIRTH_VISIT_2.MULTIPLE_NUM", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Multiple Number", :response_class => "string")

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

    # Work address one
    q = Factory(:question, :reference_identifier => "WORK_ADDRESS_1", :data_export_identifier => "BIRTH_VISIT_3.WORK_ADDRESS1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address 1", :response_class => "string")
    # Work address two
    q = Factory(:question, :reference_identifier => "WORK_ADDRESS_2", :data_export_identifier => "BIRTH_VISIT_3.WORK_ADDRESS2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address 2", :response_class => "string")
    # Work unit
    q = Factory(:question, :reference_identifier => "WORK_UNIT", :data_export_identifier => "BIRTH_VISIT_3.WORK_UNIT", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Unit", :response_class => "string")
    # Work city
    q = Factory(:question, :reference_identifier => "WORK_CITY", :data_export_identifier => "BIRTH_VISIT_3.WORK_CITY", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "City", :response_class => "string")
    # Work state
    q = Factory(:question, :reference_identifier => "WORK_STATE", :data_export_identifier => "BIRTH_VISIT_3.WORK_STATE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "IL", :response_class => "answer", :reference_identifier => "14")
    a = Factory(:answer, :question_id => q.id, :text => "MI", :response_class => "answer", :reference_identifier => "23")
    # Work zip
    q = Factory(:question, :reference_identifier => "WORK_ZIP", :data_export_identifier => "BIRTH_VISIT_3.WORK_ZIP", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Zip", :response_class => "string")
    # Work plus 4
    q = Factory(:question, :reference_identifier => "WORK_ZIP4", :data_export_identifier => "BIRTH_VISIT_3.WORK_ZIP4", :survey_section_id => survey_section.id)
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

  def create_birth_survey_with_prepopulated_mode_of_contact
    survey = Factory(:survey, :title => "INS_QUE_Birth_INT_EHPBHIPBS_M3.0_V3.0_BIRTH_VISIT_BABY_NAME_3", :access_code => "ins-que-birth-int-ehpbhipbs-m3-0-v3-0-birth-visit-baby-name-3")
    survey_section = Factory(:survey_section, :survey_id => survey.id)

    # prepopulated mode of contact
    q = Factory(:question, :reference_identifier => "prepopulated_mode_of_contact", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "CAPI", :response_class => "answer", :reference_identifier => "capi")
    a = Factory(:answer, :question_id => q.id, :text => "CATI", :response_class => "answer", :reference_identifier => "cati")
    a = Factory(:answer, :question_id => q.id, :text => "PAPI", :response_class => "answer", :reference_identifier => "papi")

    survey
  end

  def create_birth_part_one_survey_with_prepopulated_fields_for_part_two
    survey = Factory(:survey, :title => "INS_QUE_Birth_INT_EHPBHIPBS_M3.0_V3.0_PART_ONE", :access_code => "ins-que-birth-int-ehpbhipbs-m3-0-v3-0-part-one")
    survey_section = Factory(:survey_section, :survey_id => survey.id)

    # BIRTH_DELIVER
    q = Factory(:question, :reference_identifier => "BIRTH_DELIVER", :data_export_identifier => "BIRTH_VISIT_3.BIRTH_DELIVER", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "HOSPITAL", :response_class => "answer", :reference_identifier => "hospital")
    a = Factory(:answer, :question_id => q.id, :text => "BIRTHING CENTER", :response_class => "answer", :reference_identifier => "birthing_center")
    a = Factory(:answer, :question_id => q.id, :text => "AT HOME", :response_class => "answer", :reference_identifier => "at_home")
    a = Factory(:answer, :question_id => q.id, :text => "SOME OTHER PLACE", :response_class => "answer", :reference_identifier => "some_other_place")

    # RELEASE
    q = Factory(:question, :reference_identifier => "RELEASE", :data_export_identifier => "BIRTH_VISIT_3.RELEASE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "YES", :response_class => "answer", :reference_identifier => "yes")
    a = Factory(:answer, :question_id => q.id, :text => "NO", :response_class => "answer", :reference_identifier => "no")

    # MULTIPLE
    q = Factory(:question, :reference_identifier => "MULTIPLE", :data_export_identifier => "BIRTH_VISIT_3.MULTIPLE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "YES", :response_class => "answer", :reference_identifier => "yes")
    a = Factory(:answer, :question_id => q.id, :text => "NO", :response_class => "answer", :reference_identifier => "no")

    survey
  end


  def create_pv1_with_fields_for_birth_prepopulation
    survey = Factory(:survey, :title => "INS_QUE_PregVisit1_INT_EHPBHI_M3.0_V3.0", :access_code => "ins-que-pregvisit1-int-ehpbhi-m3-0-v3-0")
    survey_section = Factory(:survey_section, :survey_id => survey.id)

    # Work Name
    q = Factory(:question, :reference_identifier => "work_name", :data_export_identifier => "PREG_VISIT_1_3.WORK_NAME", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Work Name", :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")

    # Work Address
    q = Factory(:question, :reference_identifier => "work_address", :data_export_identifier => "PREG_VISIT_1_3.WORK_ADDRESS_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address", :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")

    survey
  end

  def create_birth_part_two_survey_with_prepopulated_fields_from_part_one
    survey = Factory(:survey, :title => "INS_QUE_Birth_INT_EHPBHIPBS_M3.0_V3.0_PART_TWO", :access_code => "ins-que-birth-int-ehpbhipbs-m3-0-v3-0-part-two")
    survey_section = Factory(:survey_section, :survey_id => survey.id)

    # prepopulated_birth_deliver_from_birth_visit_part_one
    q = Factory(:question, :reference_identifier => "prepopulated_birth_deliver_from_birth_visit_part_one", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "HOSPITAL", :response_class => "answer", :reference_identifier => "hospital")
    a = Factory(:answer, :question_id => q.id, :text => "BIRTHING CENTER", :response_class => "answer", :reference_identifier => "birthing_center")
    a = Factory(:answer, :question_id => q.id, :text => "AT HOME", :response_class => "answer", :reference_identifier => "at_home")
    a = Factory(:answer, :question_id => q.id, :text => "SOME OTHER PLACE", :response_class => "answer", :reference_identifier => "some_other_place")

    # prepopulated_release_from_birth_visit_part_one
    q = Factory(:question, :reference_identifier => "prepopulated_release_from_birth_visit_part_one", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "YES", :response_class => "answer", :reference_identifier => "yes")
    a = Factory(:answer, :question_id => q.id, :text => "NO", :response_class => "answer", :reference_identifier => "no")

    # prepopulated_multiple_from_birth_visit_part_one
    q = Factory(:question, :reference_identifier => "prepopulated_multiple_from_birth_visit_part_one", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "YES", :response_class => "answer", :reference_identifier => "yes")
    a = Factory(:answer, :question_id => q.id, :text => "NO", :response_class => "answer", :reference_identifier => "no")

    # prepopulated_is_valid_work_name_provided
    q = Factory(:question, :reference_identifier => "prepopulated_is_valid_work_name_provided", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE", :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE", :response_class => "answer", :reference_identifier => "false")

    # prepopulated_is_valid_work_address_provided
    q = Factory(:question, :reference_identifier => "prepopulated_is_valid_work_address_provided", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE", :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE", :response_class => "answer", :reference_identifier => "false")

    # prepopulated_is_pv_one_complete
    q = Factory(:question, :reference_identifier => "prepopulated_is_pv_one_complete", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE", :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE", :response_class => "answer", :reference_identifier => "false")

    # prepopulated_is_pv_two_complete
    q = Factory(:question, :reference_identifier => "prepopulated_is_pv_two_complete", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE", :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE", :response_class => "answer", :reference_identifier => "false")

    survey
  end

end
