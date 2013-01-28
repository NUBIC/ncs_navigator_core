# -*- coding: utf-8 -*-

module PostNatal

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

  def create_three_month_mother_int_part_two_survey_with_person_race_operational_data
    survey = Factory(:survey, :title => "INS_QUE_3MMother_INT_EHPBHI_P2_V1.1_PART_TWO", :access_code => "ins-que-3mmother-int-ehpbhi-p2-v1-1-part_two")
    survey_section = Factory(:survey_section, :survey_id => survey.id)

    # Race One
    q = Factory(:question, :reference_identifier => "RACE", :data_export_identifier => "THREE_MTH_MOTHER_RACE.RACE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Black or African American", :response_class => "answer", :reference_identifier => "2")
    a = Factory(:answer, :question_id => q.id, :text => "Other", :response_class => "answer", :reference_identifier => "neg_5")
    a = Factory(:answer, :question_id => q.id, :text => "Asian", :response_class => "answer", :reference_identifier => "4")

    # Race One Other
    q = Factory(:question, :reference_identifier => "RACE_OTH", :data_export_identifier => "THREE_MTH_MOTHER_RACE.RACE_OTH", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Korean", :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "Aborigine", :response_class => "string")

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

  def create_18mm_v2_survey_for_mold_prepopulators
    survey = Factory(:survey, :title =>
              "INS_QUE_18MMother_INT_EHPBHI_M2.2_V2.0_EIGHTEEN_MTH_MOTHER_MOLD",
                     :access_code =>
              "ins_que_18mmother_int_ehpbhi_m2_2_V2_0_eighteen_mth_mother_mold")
    survey_section = Factory(:survey_section, :survey_id => survey.id)
    q = Factory(:question, :reference_identifier =>
                                   "prepopulated_should_show_room_mold_child",
                :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE",
                :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE",
                :response_class => "answer", :reference_identifier => "false")
    survey
  end

  def create_18mm_v2_survey_part_three_for_mold_prepopulators
    survey = Factory(:survey,
                     :title =>
                            "INS_QUE_18MMother_INT_EHPBHI_M2.2_V2.0_PART_THREE",
                     :access_code =>
                            "ins_que_18mmother_int_ehpbhi_m2_2_V2_0_part_three")
    survey_section = Factory(:survey_section, :survey_id => survey.id)
    q = Factory(:question,
                :reference_identifier => "MOLD",
                :data_export_identifier => "EIGHTEEN_MTH_MOTHER_2.MOLD",
                :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :reference_identifier => "1",
                :text => "YES", :response_class => "answer")
    a = Factory(:answer, :question_id => q.id, :reference_identifier => "2",
                :text => "NO", :response_class => "answer")
    a = Factory(:answer, :question_id => q.id, :text => "REFUSED",
                :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "DON'T KNOW",
                :response_class => "answer", :reference_identifier => "neg_2")
    survey
  end

  def create_pm_child_anthr_survey_for_6_month_event
    survey = Factory(:survey,
                     :title => "INS_PM_ChildAnthro_DCI_EHPBHI_M3.1_V1.0",
                     :access_code => "ins_pm_childanthro_dci_ehpbhi_m3_1_v1_0")
    survey_section = Factory(:survey_section, :survey_id => survey.id)
    q = Factory(:question,
                :reference_identifier => "prepopulated_is_6_month_event",
                :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE",
                :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE",
                :response_class => "answer", :reference_identifier => "false")
    survey
  end

  def create_bio_child_anthr_survey_for_12_month_visit
    survey = Factory(:survey,
                     :title => "INS_BIO_ChildBlood_INT_EHPBHI_M3.1_V1.0",
                     :access_code => "ins_bio_childblood_int_ehpbhi_m3_1_v1_0")
    survey_section = Factory(:survey_section, :survey_id => survey.id)
    q = Factory(:question,
                :reference_identifier => "prepopulated_is_12_month_visit",
                :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE",
                :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE",
                :response_class => "answer", :reference_identifier => "false")
    survey
  end

  def create_con_reconsideration_for_events
    survey = Factory(:survey,
                     :title => "INS_CON_Reconsideration_DCI_EHPBHI_M3.1_V1.0",
                     :access_code =>
                               "ins_con_reconsideration_dci_ehpbhi_m3_1_v1_0")
    survey_section = Factory(:survey_section, :survey_id => survey.id)
    q = Factory(:question,
                :reference_identifier => "prepopulated_event_type",
                :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "PV1 or PV2",
                :response_class => "answer", :reference_identifier => "pv")
    a = Factory(:answer, :question_id => q.id, :text => "12 MONTH",
                :response_class => "answer",
                :reference_identifier => "twelve_mns")
    survey
  end

  def create_3mmmother_int_part_two
    survey = Factory(:survey, :title =>
              "INS_QUE_3MMother_INT_EHPBHI_P2_V1.1_PART_TWO",
                     :access_code =>
              "ins_que_3mmother_int_ehpbhi_p2_v1_1_part_two")
    survey_section = Factory(:survey_section, :survey_id => survey.id)
    q = Factory(:question, :reference_identifier =>
                                   "prepopulated_should_show_demographics",
                :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE",
                :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE",
                :response_class => "answer", :reference_identifier => "false")
    survey
  end

  def create_3month_int_child_habits
    survey = Factory(:survey, :title =>
              "INS_QUE_3Month_INT_EHPBHILIPBS_M3.1_V2.0_CHILD_HABITS",
                     :access_code =>
              "ins_que_3month_int_ehpbhilipbs_m3_1_v2_0_child_habits")
    survey_section = Factory(:survey_section, :survey_id => survey.id)
    q = Factory(:question, :reference_identifier =>
                    "prepopulated_is_prev_event_birth_li_and_set_to_complete",
                :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE",
                :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE",
                :response_class => "answer", :reference_identifier => "false")

    q = Factory(:question, :reference_identifier =>
                                            "prepopulated_is_multiple_child",
                :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE",
                :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE",
                :response_class => "answer", :reference_identifier => "false")

    q = Factory(:question, :reference_identifier =>
                    "prepopulated_is_birth_deliver_collelected_and_set_to_one",
                :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE",
                :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE",
                :response_class => "answer", :reference_identifier => "false")
    survey
  end

  def create_birth_part_one_birth_deliver
    survey = Factory(:survey,
                     :title =>
                            "INS_QUE_Birth_INT_LI_M3.1_V2.0_PART_ONE",
                     :access_code =>
                            "ins_que_birth_int_li_m3_1_V2_0_part_one")
    survey_section = Factory(:survey_section, :survey_id => survey.id)
    q = Factory(:question,
                :reference_identifier => "BIRTH_DELIVER",
                :data_export_identifier => "BIRTH_VISIT_LI_2.BIRTH_DELIVER",
                :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :reference_identifier => "1",
                :text => "HOSPITAL", :response_class => "answer")
    a = Factory(:answer, :question_id => q.id, :reference_identifier => "2",
                :text => "BIRTHING CENTER", :response_class => "answer")
    a = Factory(:answer, :question_id => q.id, :reference_identifier => "3",
                :text => "AT HOME", :response_class => "answer")
    a = Factory(:answer, :question_id => q.id, :text => "SOME OTHER PLACE",
                :response_class => "answer", :reference_identifier => "neg_5")
    survey
  end

end
