# -*- coding: utf-8 -*-

module PregnancyVisitTwo

  def create_pbs_pregnancy_visit_2_with_birth_address_operational_data
    survey = Factory(:survey, :title => "INS_QUE_PregVisit2_INT_EHPBHIPBS_M3.0_V3.0", :access_code => "ins-que-pregvisit2-int-ehpbhipbs-m3-0-v3-0_test")
    survey_section = Factory(:survey_section, :survey_id => survey.id)

    # Address One
    q = Factory(:question, :reference_identifier => "B_ADDRESS_1", :data_export_identifier => "PREG_VISIT_2_3.B_ADDRESS_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address 1", :response_class => "string")
    # Address Two
    q = Factory(:question, :reference_identifier => "B_ADDRESS_2", :data_export_identifier => "PREG_VISIT_2_3.B_ADDRESS_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address 2", :response_class => "string")
    # City
    q = Factory(:question, :reference_identifier => "B_CITY", :data_export_identifier => "PREG_VISIT_2_3.B_CITY", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "City", :response_class => "string")
    # State
    q = Factory(:question, :reference_identifier => "B_STATE", :data_export_identifier => "PREG_VISIT_2_3.B_STATE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "IL", :response_class => "answer", :reference_identifier => "14")
    a = Factory(:answer, :question_id => q.id, :text => "MI", :response_class => "answer", :reference_identifier => "23")
    # Zip
    q = Factory(:question, :reference_identifier => "B_ZIPCODE", :data_export_identifier => "PREG_VISIT_2_3.B_ZIPCODE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Zip", :response_class => "string")

    survey
  end

  def create_pbs_pregnancy_visit_2_with_work_address_operational_data
    survey = Factory(:survey, :title => "INS_QUE_PregVisit2_INT_EHPBHIPBS_M3.0_V3.0", :access_code => "ins-que-pregvisit2-int-ehpbhipbs-m3-0-v3-0_test")
    survey_section = Factory(:survey_section, :survey_id => survey.id)

    # Address One
    q = Factory(:question, :reference_identifier => "WORK_ADDRESS_1", :data_export_identifier => "PREG_VISIT_2_3.WORK_ADDRESS_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address 1", :response_class => "string")
    # Address Two
    q = Factory(:question, :reference_identifier => "WORK_ADDRESS_2", :data_export_identifier => "PREG_VISIT_2_3.WORK_ADDRESS_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address 2", :response_class => "string")
    # Unit
    q = Factory(:question, :reference_identifier => "WORK_UNIT", :data_export_identifier => "PREG_VISIT_2_3.WORK_UNIT", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Unit", :response_class => "string")
    # City
    q = Factory(:question, :reference_identifier => "WORK_CITY", :data_export_identifier => "PREG_VISIT_2_3.WORK_CITY", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "City", :response_class => "string")
    # State
    q = Factory(:question, :reference_identifier => "WORK_STATE", :data_export_identifier => "PREG_VISIT_2_3.WORK_STATE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "IL", :response_class => "answer", :reference_identifier => "14")
    a = Factory(:answer, :question_id => q.id, :text => "MI", :response_class => "answer", :reference_identifier => "23")
    # Zip
    q = Factory(:question, :reference_identifier => "WORK_ZIPCODE", :data_export_identifier => "PREG_VISIT_2_3.WORK_ZIPCODE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Zip", :response_class => "string")
    # Zip 4
    q = Factory(:question, :reference_identifier => "WORK_ZIP4", :data_export_identifier => "PREG_VISIT_2_3.WORK_ZIP4", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "plus 4", :response_class => "string")

    survey
  end

  def create_pbs_pregnancy_visit_2_with_confirm_work_address_operational_data
    survey = Factory(:survey, :title => "INS_QUE_PregVisit2_INT_EHPBHIPBS_M3.0_V3.0", :access_code => "ins-que-pregvisit2-int-ehpbhipbs-m3-0-v3-0_test")
    survey_section = Factory(:survey_section, :survey_id => survey.id)

    # Address One
    q = Factory(:question, :reference_identifier => "CWORK_ADDRESS_1", :data_export_identifier => "PREG_VISIT_2_3.CWORK_ADDRESS_1", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address 1", :response_class => "string")
    # Address Two
    q = Factory(:question, :reference_identifier => "CWORK_ADDRESS_2", :data_export_identifier => "PREG_VISIT_2_3.CWORK_ADDRESS_2", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Address 2", :response_class => "string")
    # Unit
    q = Factory(:question, :reference_identifier => "CWORK_UNIT", :data_export_identifier => "PREG_VISIT_2_3.CWORK_UNIT", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Unit", :response_class => "string")
    # City
    q = Factory(:question, :reference_identifier => "CWORK_CITY", :data_export_identifier => "PREG_VISIT_2_3.CWORK_CITY", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "City", :response_class => "string")
    # State
    q = Factory(:question, :reference_identifier => "CWORK_STATE", :data_export_identifier => "PREG_VISIT_2_3.CWORK_STATE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "IL", :response_class => "answer", :reference_identifier => "14")
    a = Factory(:answer, :question_id => q.id, :text => "MI", :response_class => "answer", :reference_identifier => "23")
    # Zip
    q = Factory(:question, :reference_identifier => "CWORK_ZIPCODE", :data_export_identifier => "PREG_VISIT_2_3.CWORK_ZIPCODE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Zip", :response_class => "string")
    # Zip 4
    q = Factory(:question, :reference_identifier => "CWORK_ZIP4", :data_export_identifier => "PREG_VISIT_2_3.CWORK_ZIP4", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "plus 4", :response_class => "string")

    survey
  end

  def create_pbs_pregnancy_visit_2_with_due_date
    survey = Factory(:survey, :title => "INS_QUE_PregVisit2_INT_EHPBHIPBS_M3.0_V3.0", :access_code => "ins-que-pregvisit2-int-ehpbhipbs-m3-0-v3-0_test")
    survey_section = Factory(:survey_section, :survey_id => survey.id)
    # Pregnant
    q = Factory(:question, :reference_identifier => "PREGNANT", :data_export_identifier => "PREG_VISIT_2_3.PREGNANT", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Yes", :response_class => "answer", :reference_identifier => "1")

    # Due Date
    q = Factory(:question, :reference_identifier => "DUE_DATE", :data_export_identifier => "PREG_VISIT_2_3.DUE_DATE", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "Due Date", :response_class => "string")
    a = Factory(:answer, :question_id => q.id, :text => "Refused", :response_class => "answer", :reference_identifier => "neg_1")
    a = Factory(:answer, :question_id => q.id, :text => "Don't know", :response_class => "answer", :reference_identifier => "neg_2")
    survey
  end

  def create_pv1_with_fields_for_pv2_prepopulation
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

  def create_pbs_pregnancy_visit_2_with_prepopulated_fields
    survey = Factory(:survey, :title => "INS_QUE_PregVisit2_INT_EHPBHIPBS_M3.0_V3.0", :access_code => "ins-que-pregvisit2-int-ehpbhipbs-m3-0-v3-0_test")
    survey_section = Factory(:survey_section, :survey_id => survey.id)

    # prepopulated_is_work_name_previously_collected_and_valid
    q = Factory(:question, :reference_identifier => "prepopulated_is_work_name_previously_collected_and_valid", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE", :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE", :response_class => "answer", :reference_identifier => "false")

    # prepopulated_is_work_address_previously_collected_and_valid
    q = Factory(:question, :reference_identifier => "prepopulated_is_work_address_previously_collected_and_valid", :survey_section_id => survey_section.id)
    a = Factory(:answer, :question_id => q.id, :text => "TRUE", :response_class => "answer", :reference_identifier => "true")
    a = Factory(:answer, :question_id => q.id, :text => "FALSE", :response_class => "answer", :reference_identifier => "false")

    survey
  end

end