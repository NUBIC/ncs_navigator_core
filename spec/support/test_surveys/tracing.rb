# -*- coding: utf-8 -*-

module Tracing

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
    q = Factory(:question, :reference_identifier => "NEW_ADDRESS1", :data_export_identifier => "TRACING_INT.NEW_ADDRESS1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address 1", :response_class => "string")
    # Address Two
    q = Factory(:question, :reference_identifier => "NEW_ADDRESS2", :data_export_identifier => "TRACING_INT.NEW_ADDRESS2", :survey_section_id => survey_section.id)
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

  def create_tracing_module_survey_with_telephone_operational_data
    survey = Factory(:survey, :title => "INS_QUE_Tracing_INT_EHPBHILIPBS_M3.0_V1.0", :access_code => "ins-que-tracing-int-ehpbhilipbs-m3-0-v1-0")
    survey_section = Factory(:survey_section, :survey_id => survey.id)

    # Home Phone
    q = Factory(:question, :reference_identifier => "HOME_PHONE", :data_export_identifier => "TRACING_INT.HOME_PHONE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Phone Number", :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "REFUSED", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "DON'T KNOW", :response_class => "answer", :reference_identifier => "neg_2")
    a = Factory(:answer, :question_id => q.id, :text => "NO HOME PHONE", :response_class => "answer", :reference_identifier => "neg_7")
    # Cell Phone
    q = Factory(:question, :reference_identifier => "CELL_PHONE", :data_export_identifier => "TRACING_INT.CELL_PHONE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Phone Number", :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "REFUSED", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "DON'T KNOW", :response_class => "answer", :reference_identifier => "neg_2")
    a = Factory(:answer, :question_id => q.id, :text => "NO CELL PHONE", :response_class => "answer", :reference_identifier => "neg_7")
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

  def create_tracing_module_survey_with_email_operational_data
    survey = Factory(:survey, :title => "INS_QUE_Tracing_INT_EHPBHILIPBS_M3.0_V1.0", :access_code => "ins-que-tracing-int-ehpbhilipbs-m3-0-v1-0")
    survey_section = Factory(:survey_section, :survey_id => survey.id)
    # Email
    q = Factory(:question, :reference_identifier => "EMAIL", :data_export_identifier => "TRACING_INT.EMAIL", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Email", :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "REFUSED", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "DON'T KNOW", :response_class => "answer", :reference_identifier => "neg_2")
    a = Factory(:answer, :question_id => q.id, :text => "NO EMAIL ACCOUNT", :response_class => "answer", :reference_identifier => "neg_7")

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

  def create_tracing_survey_with_prepopulated_fields
    survey = Factory(:survey, :title => "INS_QUE_Tracing_INT_EHPBHILIPBS_M3.0_V1.0", :access_code => "ins-que-tracing-int-ehpbhilipbs-m3-0-v1-0")
    survey_section = Factory(:survey_section, :survey_id => survey.id)

    # prepopulated mode of contact
    q = Factory(:question, :reference_identifier => "prepopulated_mode_of_contact", :data_export_identifier => "prepopulated_mode_of_contact", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "CAPI", :response_class => "answer", :reference_identifier => "capi")
    a = Factory(:answer, :question_id => q.id, :text => "CATI", :response_class => "answer", :reference_identifier => "cati")
    a = Factory(:answer, :question_id => q.id, :text => "PAPI", :response_class => "answer", :reference_identifier => "papi")

    # prepopulated_is_showing_address_for_tracing
    q = Factory(:question, :reference_identifier => "prepopulated_should_show_address_for_tracing", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE", :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE", :response_class => "answer", :reference_identifier => "false")

    # prepopulated_is_address_provided
    q = Factory(:question, :reference_identifier => "prepopulated_is_address_provided", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE", :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE", :response_class => "answer", :reference_identifier => "false")

    # prepopulated_is_home_phone_provided
    q = Factory(:question, :reference_identifier => "prepopulated_is_home_phone_provided", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE", :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE", :response_class => "answer", :reference_identifier => "false")

    # prepopulated_is_valid_cell_phone_provided
    q = Factory(:question, :reference_identifier => "prepopulated_is_valid_cell_phone_provided", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE", :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE", :response_class => "answer", :reference_identifier => "false")

    # prepopulated_is_valid_cell_phone_2_provided
    q = Factory(:question, :reference_identifier => "prepopulated_is_valid_cell_phone_2_provided", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE", :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE", :response_class => "answer", :reference_identifier => "false")

    # CELL_PHONE_2
    q = Factory(:question, :reference_identifier => "CELL_PHONE_2", :data_export_identifier => "TRACING_INT.CELL_PHONE_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "YES", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "NO", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "REFUSED", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "DON'T KNOW", :response_class => "answer", :reference_identifier => "neg_2")

    # prepopulated_is_valid_cell_phone_3_provided
    q = Factory(:question, :reference_identifier => "prepopulated_is_valid_cell_phone_3_provided", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE", :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE", :response_class => "answer", :reference_identifier => "false")

    # CELL_PHONE_3
    q = Factory(:question, :reference_identifier => "CELL_PHONE_3", :data_export_identifier => "TRACING_INT.CELL_PHONE_3", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "YES", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "NO", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "REFUSED", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "DON'T KNOW", :response_class => "answer", :reference_identifier => "neg_2")

    # prepopulated_is_valid_cell_phone_4_provided
    q = Factory(:question, :reference_identifier => "prepopulated_is_valid_cell_phone_4_provided", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE", :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE", :response_class => "answer", :reference_identifier => "false")

    # CELL_PHONE_4
    q = Factory(:question, :reference_identifier => "CELL_PHONE_4", :data_export_identifier => "TRACING_INT.CELL_PHONE_4", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "YES", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "NO", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "REFUSED", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "DON'T KNOW", :response_class => "answer", :reference_identifier => "neg_2")

    # prepopulated_should_show_email_for_tracing
    q = Factory(:question, :reference_identifier => "prepopulated_should_show_email_for_tracing", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE", :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE", :response_class => "answer", :reference_identifier => "false")

    # prepopulated_is_valid_email_provided
    q = Factory(:question, :reference_identifier => "prepopulated_is_valid_email_provided", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE", :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE", :response_class => "answer", :reference_identifier => "false")

    # prepopulated_is_valid_email_appt_provided
    q = Factory(:question, :reference_identifier => "prepopulated_is_valid_email_appt_provided", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE", :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE", :response_class => "answer", :reference_identifier => "false")

    # EMAIL_APPT
    q = Factory(:question, :reference_identifier => "EMAIL_APPT", :data_export_identifier => "TRACING_INT.EMAIL_APPT", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "YES", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "NO", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "REFUSED", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "DON'T KNOW", :response_class => "answer", :reference_identifier => "neg_2")

    # prepopulated_is_valid_email_questionnaire_provided
    q = Factory(:question, :reference_identifier => "prepopulated_is_valid_email_questionnaire_provided", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE", :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE", :response_class => "answer", :reference_identifier => "false")

    # EMAIL_QUEST
    q = Factory(:question, :reference_identifier => "EMAIL_QUEST", :data_export_identifier => "TRACING_INT.EMAIL_QUEST", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "YES", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "NO", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "REFUSED", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "DON'T KNOW", :response_class => "answer", :reference_identifier => "neg_2")

    # prepopulated_should_show_contact_for_tracing
    q = Factory(:question, :reference_identifier => "prepopulated_should_show_contact_for_tracing", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE", :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE", :response_class => "answer", :reference_identifier => "false")

    # prepopulated_is_valid_contact_for_all_provided
    q = Factory(:question, :reference_identifier => "prepopulated_is_valid_contact_for_all_provided", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE", :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE", :response_class => "answer", :reference_identifier => "false")

    q = Factory(:question, :reference_identifier => "CONTACT_RELATE_1", :data_export_identifier => "TRACING_INT.CONTACT_RELATE_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "MOTHER/FATHER", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "BROTHER/SISTER", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "AUNT/UNCLE", :response_class => "answer", :reference_identifier => "3")
    a = Factory(:answer, :question_id => q.id, :text => "FRIEND", :response_class => "answer", :reference_identifier => "6")

    q = Factory(:question, :reference_identifier => "CONTACT_RELATE_2", :data_export_identifier => "TRACING_INT.CONTACT_RELATE_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "MOTHER/FATHER", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "BROTHER/SISTER", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "AUNT/UNCLE", :response_class => "answer", :reference_identifier => "3")
    a = Factory(:answer, :question_id => q.id, :text => "FRIEND", :response_class => "answer", :reference_identifier => "6")

    q = Factory(:question, :reference_identifier => "CONTACT_RELATE_3", :data_export_identifier => "TRACING_INT.CONTACT_RELATE_3", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "MOTHER/FATHER", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "BROTHER/SISTER", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "AUNT/UNCLE", :response_class => "answer", :reference_identifier => "3")
    a = Factory(:answer, :question_id => q.id, :text => "FRIEND", :response_class => "answer", :reference_identifier => "6")

    # prepopulated_is_event_type_birth
    q = Factory(:question, :reference_identifier => "prepopulated_is_event_type_birth", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE", :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE", :response_class => "answer", :reference_identifier => "false")

    # prepopulated_is_event_type_pbs_participant_eligibility_screening
    q = Factory(:question, :reference_identifier => "prepopulated_is_event_type_pbs_participant_eligibility_screening", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE", :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE", :response_class => "answer", :reference_identifier => "false")

    # prepopulated_should_show_prev_city_for_tracing
    q = Factory(:question, :reference_identifier => "prepopulated_is_prev_city_provided", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE", :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE", :response_class => "answer", :reference_identifier => "false")

    # PREV_CITY
    q = Factory(:question, :reference_identifier => "PREV_CITY", :data_export_identifier => "TRACING_INT.PREV_CITY", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "YES", :response_class => "answer", :reference_identifier => "1")
    a = Factory(:answer, :question_id => q.id, :text => "NO", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "REFUSED", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "DON'T KNOW", :response_class => "answer", :reference_identifier => "neg_2")

    # prepopulated_valid_driver_license_provided
    q = Factory(:question, :reference_identifier => "prepopulated_valid_driver_license_provided", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE", :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE", :response_class => "answer", :reference_identifier => "false")

    # DR_LICENSE_NUM
    q = Factory(:question, :reference_identifier => "DR_LICENSE_NUM", :data_export_identifier => "TRACING_INT.DR_LICENSE_NUM", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "License Number", :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "REFUSED", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "DON'T KNOW", :response_class => "answer", :reference_identifier => "neg_2")

    survey
  end

end
