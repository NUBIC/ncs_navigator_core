require 'spec_helper'

describe OperationalDataExtractor do

  before(:each) do
    create_missing_in_error_ncs_codes(Instrument)
    create_missing_in_error_ncs_codes(Address)
    create_missing_in_error_ncs_codes(DwellingUnit)
    create_missing_in_error_ncs_codes(Telephone)
    create_missing_in_error_ncs_codes(Email)
    create_missing_in_error_ncs_codes(Participant)
    create_missing_in_error_ncs_codes(PpgDetail)
  end

  it "sets up the test properly" do
    
    person = Factory(:person)
    survey = create_survey_with_person_operational_data
    
    survey.sections.size.should == 1
    survey.sections.first.questions.size.should == 9
    
    survey.sections.first.questions.each do |q| 
      case q.reference_identifier
      when "R_FNAME", "R_LNAME", "AGE", "PERSON_DOB"
        q.answers.size.should == 3
      when "AGE_RANGE"
        q.answers.size.should == 9
      when "ETHNICITY"
        q.answers.size.should == 2
      when "PERSON_LANG"
        q.answers.size.should == 3
      when "PERSON_LANG_OTH"
        q.answers.size.should == 1
      end
    end
    
  end

  # R_FNAME               Person.first_name
  # R_LNAME               Person.last_name
  # PERSON_DOB            Person.person_dob
  # AGE                   Person.age
  # AGE_RANGE             Person.age_range_code             AGE_RANGE_CL1
  # ETHNICITY             Person.ethnic_group_code          ETHNICITY_CL1
  # PERSON_LANG           Person.language_code              LANGUAGE_CL2
  # PERSON_LANG_OTH       Person.language_other
  it "extracts person operational data from the survey responses" do    
    
    age_range     = Factory(:ncs_code, :list_name => "AGE_RANGE_CL1", :display_text => "25-34", :local_code => 3)
    ethnic_group  = Factory(:ncs_code, :list_name => "ETHNICITY_CL1", :display_text => "Not Hispanic or Latino", :local_code => 2)
    language      = Factory(:ncs_code, :list_name => "LANGUAGE_CL2", :display_text => "English", :local_code => 1)

    age_eligible  = Factory(:ncs_code, :list_name => "AGE_ELIGIBLE_CL2", :display_text => "Age-Eligible", :local_code => 3)
    age_eligible2 = Factory(:ncs_code, :list_name => "AGE_ELIGIBLE_CL4", :display_text => "Age-Eligible", :local_code => 3)
    
    person = Factory(:person)
    participant = Factory(:participant, :person => person)
    ppl = Factory(:participant_person_link, :participant => participant, :person => person)
    
    survey = create_survey_with_person_operational_data
    survey_section = survey.sections.first
    response_set = person.start_instrument(survey)
    response_set.responses.size.should == 0
    survey_section.questions.each do |q|
      case q.reference_identifier
      when "R_FNAME"
        answer = q.answers.select { |a| a.response_class == "string" }.first
        Factory(:response, :survey_section_id => survey_section.id, :string_value => "Jo", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "R_LNAME"
        answer = q.answers.select { |a| a.response_class == "string" }.first
        Factory(:response, :survey_section_id => survey_section.id, :string_value => "Stafford", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "PERSON_DOB"
        answer = q.answers.select { |a| a.response_class == "date" }.first
        Factory(:response, :survey_section_id => survey_section.id, :datetime_value => Date.parse("01/11/1981"), :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "AGE"
        answer = q.answers.select { |a| a.response_class == "integer" }.first
        Factory(:response, :survey_section_id => survey_section.id, :integer_value => 30, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "AGE_RANGE"
        answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "#{age_range.local_code}" }.first
        Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "ETHNICITY"
        answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "#{ethnic_group.local_code}" }.first
        Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "PERSON_LANG"
        answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "#{language.local_code}" }.first
        Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "PERSON_LANG_OTH"
        ## Do nothing
      when "AGE_ELIG"
        answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "#{age_eligible.local_code}" }.first
        Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)        
      end
    end
    
    response_set.responses.reload
    response_set.responses.size.should == 8
    
    OperationalDataExtractor.process(response_set)
    
    person = Person.find(person.id)
    person.first_name.should == "Jo"
    person.last_name.should == "Stafford"
    person.person_dob.should == "1981-01-11"
    person.age.should == 30
    
    person.age_range.should == age_range
    person.ethnic_group.should == ethnic_group
    person.language.should == language
    
    person.participant.pid_age_eligibility
    
  end
  
  # ADDRESS_1             Address.address_one
  # ADDRESS_2             Address.address_two
  # UNIT                  Address.unit
  # CITY                  Address.city
  # STATE                 Address.state_code                STATE_CL1
  # ZIP                   Address.zip
  # ZIP4                  Address.zip4
  it "extracts address operational data from the survey responses" do
    state = Factory(:ncs_code, :list_name => "STATE_CL1", :display_text => "IL", :local_code => 14)
    
    person = Factory(:person)
    person.addresses.size.should == 0
    
    survey = create_survey_with_address_operational_data
    survey_section = survey.sections.first
    response_set = person.start_instrument(survey)
    response_set.responses.size.should == 0
    survey_section.questions.each do |q|
      case q.reference_identifier
      when "ADDRESS_1"
        answer = q.answers.select { |a| a.response_class == "string" }.first
        Factory(:response, :survey_section_id => survey_section.id, :string_value => "123 Easy St.", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "ADDRESS_2"
        answer = q.answers.select { |a| a.response_class == "string" }.first
        Factory(:response, :survey_section_id => survey_section.id, :string_value => "", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "UNIT"
        answer = q.answers.select { |a| a.response_class == "string" }.first
        Factory(:response, :survey_section_id => survey_section.id, :string_value => "", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "CITY"
        answer = q.answers.select { |a| a.response_class == "string" }.first
        Factory(:response, :survey_section_id => survey_section.id, :string_value => "Chicago", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "STATE"
        answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "#{state.local_code}" }.first
        Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "ZIP"
        answer = q.answers.select { |a| a.response_class == "string" }.first
        Factory(:response, :survey_section_id => survey_section.id, :string_value => "65432", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "ZIP4"
        answer = q.answers.select { |a| a.response_class == "string" }.first
        Factory(:response, :survey_section_id => survey_section.id, :string_value => "1234", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      end
    end
    
    response_set.responses.reload
    response_set.responses.size.should == 7
    
    OperationalDataExtractor.process(response_set)
    
    person  = Person.find(person.id)
    person.addresses.size.should == 1
    address = person.addresses.first
    address.to_s.should == "123 Easy St. Chicago IL 65432-1234"
    
  end


  it "extracts mail address operational data from the survey responses" do
    
    state = Factory(:ncs_code, :list_name => "STATE_CL1", :display_text => "IL", :local_code => 14)
    
    person = Factory(:person)
    person.addresses.size.should == 0
    
    survey = create_survey_with_mail_address_operational_data
    survey_section = survey.sections.first
    response_set = person.start_instrument(survey)
    response_set.responses.size.should == 0
    survey_section.questions.each do |q|
      case q.reference_identifier
      when "MAIL_ADDRESS_1"
        answer = q.answers.select { |a| a.response_class == "string" }.first
        Factory(:response, :survey_section_id => survey_section.id, :string_value => "123 Easy St.", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "MAIL_ADDRESS_2"
        answer = q.answers.select { |a| a.response_class == "string" }.first
        Factory(:response, :survey_section_id => survey_section.id, :string_value => "", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "MAIL_UNIT"
        answer = q.answers.select { |a| a.response_class == "string" }.first
        Factory(:response, :survey_section_id => survey_section.id, :string_value => "", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "MAIL_CITY"
        answer = q.answers.select { |a| a.response_class == "string" }.first
        Factory(:response, :survey_section_id => survey_section.id, :string_value => "Chicago", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "MAIL_STATE"
        answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "#{state.local_code}" }.first
        Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "MAIL_ZIP"
        answer = q.answers.select { |a| a.response_class == "string" }.first
        Factory(:response, :survey_section_id => survey_section.id, :string_value => "65432", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "MAIL_ZIP4"
        answer = q.answers.select { |a| a.response_class == "string" }.first
        Factory(:response, :survey_section_id => survey_section.id, :string_value => "1234", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      end
    end
    
    response_set.responses.reload
    response_set.responses.size.should == 7
    
    OperationalDataExtractor.process(response_set)
    
    person  = Person.find(person.id)
    person.addresses.size.should == 1
    address = person.addresses.first
    address.to_s.should == "123 Easy St. Chicago IL 65432-1234"
    
  end
  
  it "extracts telephone operational data from the survey responses" do
    
    home = Factory(:ncs_code, :list_name => "PHONE_TYPE_CL1", :display_text => "Home", :local_code => 1)
    work = Factory(:ncs_code, :list_name => "PHONE_TYPE_CL1", :display_text => "Work", :local_code => 2)
    cell = Factory(:ncs_code, :list_name => "PHONE_TYPE_CL1", :display_text => "Cell", :local_code => 3)
    frre = Factory(:ncs_code, :list_name => "PHONE_TYPE_CL1", :display_text => "Friend/Relative", :local_code => 4)
    fax  = Factory(:ncs_code, :list_name => "PHONE_TYPE_CL1", :display_text => "Fax", :local_code => 5)
    oth  = Factory(:ncs_code, :list_name => "PHONE_TYPE_CL1", :display_text => "Other", :local_code => -5)

    person = Factory(:person)
    person.telephones.size.should == 0

    survey = create_survey_with_telephone_operational_data
    survey_section = survey.sections.first
    response_set = person.start_instrument(survey)
    response_set.responses.size.should == 0
      
    survey_section.questions.each do |q|
      case q.reference_identifier
      when "PHONE_NBR"
        answer = q.answers.select { |a| a.response_class == "string" }.first
        Factory(:response, :survey_section_id => survey_section.id, :string_value => "3125551234", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "PHONE_NBR_OTH"
        answer = q.answers.select { |a| a.response_class == "string" }.first
        Factory(:response, :survey_section_id => survey_section.id, :string_value => "", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "PHONE_TYPE"
        answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "#{cell.local_code}" }.first
        Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "PHONE_TYPE_OTH"
        answer = q.answers.select { |a| a.response_class == "string" }.first
        Factory(:response, :survey_section_id => survey_section.id, :string_value => "", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "HOME_PHONE"
        answer = q.answers.select { |a| a.response_class == "string" }.first
        Factory(:response, :survey_section_id => survey_section.id, :string_value => "3125554321", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "CELL_PHONE_2"
        answer = q.answers.select { |a| a.response_class == "answer" }.first
        Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "CELL_PHONE_4"
        answer = q.answers.select { |a| a.response_class == "answer" }.first
        Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "CELL_PHONE"
        answer = q.answers.select { |a| a.response_class == "string" }.first
        Factory(:response, :survey_section_id => survey_section.id, :string_value => "3125557890", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      end
    end
    
    response_set.responses.reload
    response_set.responses.size.should == 8
    
    OperationalDataExtractor.process(response_set)
    
    person  = Person.find(person.id)
    person.telephones.size.should == 3
    person.telephones.each do |t|
      t.phone_type.should_not be_nil
      t.phone_nbr[0,6].should == "312555"
    end
    
  end
  
  it "extracts email information from the survey responses" do
    
    home = Factory(:ncs_code, :list_name => "EMAIL_TYPE_CL1", :display_text => "Personal", :local_code => 1)
    work = Factory(:ncs_code, :list_name => "EMAIL_TYPE_CL1", :display_text => "Work", :local_code => 2)

    person = Factory(:person)
    person.emails.size.should == 0

    survey = create_survey_with_email_operational_data
    survey_section = survey.sections.first
    response_set = person.start_instrument(survey)
    response_set.responses.size.should == 0

    survey_section.questions.each do |q|
      case q.reference_identifier
      when "EMAIL"
        answer = q.answers.select { |a| a.response_class == "string" }.first
        Factory(:response, :survey_section_id => survey_section.id, :string_value => "email@dev.null", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "EMAIL_TYPE"
        answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "#{home.local_code}" }.first
        Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      end
    end
    
    response_set.responses.reload
    response_set.responses.size.should == 2
    
    OperationalDataExtractor.process(response_set)
    
    person  = Person.find(person.id)
    person.emails.size.should == 1
    person.emails.first.email.should == "email@dev.null"
    person.emails.first.email_type.local_code.should == 1

  end


  # PREGNANT              PpgDetail.ppg_first               PPG_STATUS_CL2/PREGNANCY_STATUS_CL1
  # ORIG_DUE_DATE         PpgDetail.orig_due_date
  # TRYING                PpgDetail.ppg_first               PPG_STATUS_CL2/PREGNANCY_TRYING_STATUS_CL2
  # ** reasons to set ppg5
  # HYSTER                PpgDetail.ppg_first               PPG_STATUS_CL2
  # OVARIES               PpgDetail.ppg_first               PPG_STATUS_CL2
  # TUBES_TIED            PpgDetail.ppg_first               PPG_STATUS_CL2
  # MENOPAUSE             PpgDetail.ppg_first               PPG_STATUS_CL2
  # MED_UNABLE            PpgDetail.ppg_first               PPG_STATUS_CL2
  # MED_UNABLE_OTH        PpgDetail.ppg_first               PPG_STATUS_CL2
  # **
  # PPG_FIRST             PpgDetail.ppg_first               PPG_STATUS_CL2
  it "sets the ppg detail ppg status to 1 if the person responds that they are pregnant" do
    
    person = Factory(:person)
    participant = Factory(:participant, :person => person)
    ppl = Factory(:participant_person_link, :participant => participant, :person => person)
    
    ppg1 = Factory(:ncs_code, :list_name => "PPG_STATUS_CL2", :display_text => "PPG Group 1", :local_code => 1)
    
    survey = create_survey_with_ppg_detail_operational_data
    survey_section = survey.sections.first
    response_set = person.start_instrument(survey)
    response_set.responses.size.should == 0
    
    survey_section.questions.each do |q|
      case q.reference_identifier
      when "PREGNANT"
        answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "#{ppg1.local_code}" }.first
        Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "ORIG_DUE_DATE"
        answer = q.answers.select { |a| a.response_class == "date" }.first
        Factory(:response, :survey_section_id => survey_section.id, :datetime_value => "2011-12-25", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      end
    end
    
    response_set.responses.reload
    response_set.responses.size.should == 2
    
    OperationalDataExtractor.process(response_set)
    
    person  = Person.find(person.id)
    participant = person.participant
    participant.ppg_details.size.should == 1
    participant.ppg_details.first.ppg_first.local_code.should == 1
    participant.ppg_status.local_code.should == 1
    participant.due_date.should == "2011-12-25"
    
  end

  it "sets the ppg detail ppg status to 2 if the person responds that they are trying to become pregnant" do
    
    person = Factory(:person)
    participant = Factory(:participant, :person => person)
    ppl = Factory(:participant_person_link, :participant => participant, :person => person)
    
    ppg2 = Factory(:ncs_code, :list_name => "PPG_STATUS_CL2", :display_text => "PPG Group 2", :local_code => 2)
    
    survey = create_survey_with_ppg_detail_operational_data
    survey_section = survey.sections.first
    response_set = person.start_instrument(survey)
    response_set.responses.size.should == 0
    
    survey_section.questions.each do |q|
      case q.reference_identifier
      when "TRYING"
        answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "1" }.first
        Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      end
    end
    
    response_set.responses.reload
    response_set.responses.size.should == 1
    
    OperationalDataExtractor.process(response_set)
    
    person  = Person.find(person.id)
    participant = person.participant
    participant.ppg_details.size.should == 1
    participant.ppg_details.first.ppg_first.local_code.should == 2
    participant.ppg_status.local_code.should == 2
    participant.due_date.should be_nil
    
  end


  it "sets the ppg detail ppg status to 5 if the person responds that they are unable to become pregnant" do
    
    person = Factory(:person)
    participant = Factory(:participant, :person => person)
    ppl = Factory(:participant_person_link, :participant => participant, :person => person)
    
    ppg5 = Factory(:ncs_code, :list_name => "PPG_STATUS_CL2", :display_text => "PPG Group 5", :local_code => 5)
    
    survey = create_survey_with_ppg_detail_operational_data
    survey_section = survey.sections.first
    response_set = person.start_instrument(survey)
    response_set.responses.size.should == 0
    
    survey_section.questions.each do |q|
      case q.reference_identifier
      when "HYSTER"
        answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "1" }.first
        Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      end
    end
    
    response_set.responses.reload
    response_set.responses.size.should == 1
    
    OperationalDataExtractor.process(response_set)
    
    person  = Person.find(person.id)
    participant = person.participant
    participant.ppg_details.size.should == 1
    participant.ppg_details.first.ppg_first.local_code.should == 5
    participant.ppg_status.local_code.should == 5
    participant.due_date.should be_nil
  end


end