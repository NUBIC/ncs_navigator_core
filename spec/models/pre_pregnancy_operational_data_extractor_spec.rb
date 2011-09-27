require 'spec_helper'

describe PrePregnancyOperationalDataExtractor do

  before(:each) do
    create_missing_in_error_ncs_codes(Instrument)
    create_missing_in_error_ncs_codes(Participant)
    create_missing_in_error_ncs_codes(PpgDetail)
    create_missing_in_error_ncs_codes(PpgStatusHistory)
    create_missing_in_error_ncs_codes(Telephone)
    create_missing_in_error_ncs_codes(Email)
  end
  
  it "extracts person operational data from the survey responses" do
    
    married = Factory(:ncs_code, :list_name => "MARITAL_STATUS_CL1", :display_text => "Married", :local_code => 1)

    age_eligible  = Factory(:ncs_code, :list_name => "AGE_ELIGIBLE_CL2", :display_text => "Age-Eligible", :local_code => 3)
    age_eligible2 = Factory(:ncs_code, :list_name => "AGE_ELIGIBLE_CL4", :display_text => "Age-Eligible", :local_code => 3)
    
    person = Factory(:person)
    participant = Factory(:participant, :person => person)
    ppl = Factory(:participant_person_link, :participant => participant, :person => person)
    
    survey = create_pre_pregnancy_survey_with_person_operational_data
    survey_section = survey.sections.first
    response_set = person.start_instrument(survey)
    response_set.responses.size.should == 0
    survey_section.questions.each do |q|
      case q.data_export_identifier
      when "PRE_PREG.R_FNAME"
        answer = q.answers.select { |a| a.response_class == "string" }.first
        Factory(:response, :survey_section_id => survey_section.id, :string_value => "Jo", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "PRE_PREG.R_LNAME"
        answer = q.answers.select { |a| a.response_class == "string" }.first
        Factory(:response, :survey_section_id => survey_section.id, :string_value => "Stafford", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "PRE_PREG.PERSON_DOB"
        answer = q.answers.select { |a| a.response_class == "date" }.first
        Factory(:response, :survey_section_id => survey_section.id, :datetime_value => Date.parse("01/11/1981"), :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "PRE_PREG.MARISTAT"
        answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "#{married.local_code}" }.first
        Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      end
    end
    
    response_set.responses.reload
    response_set.responses.size.should == 4
    
    PrePregnancyOperationalDataExtractor.extract_data(response_set)
    
    person = Person.find(person.id)
    person.first_name.should == "Jo"
    person.last_name.should == "Stafford"
    person.person_dob.should == "1981-01-11"
    person.age.should == 30
    
    person.marital_status.should == married
  end
  
  it "extracts cell phone operational data from the survey responses" do
    
    cell = Factory(:ncs_code, :list_name => "PHONE_TYPE_CL1", :display_text => "Cell", :local_code => 3)
    
    person = Factory(:person)
    person.telephones.size.should == 0

    survey = create_pre_pregnancy_survey_with_telephone_operational_data
    survey_section = survey.sections.first
    response_set = person.start_instrument(survey)
    response_set.responses.size.should == 0
      
    survey_section.questions.each do |q|
      case q.data_export_identifier
      when "PRE_PREG.CELL_PHONE_2"
        answer = q.answers.select { |a| a.response_class == "answer" }.first
        Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "PRE_PREG.CELL_PHONE_4"
        answer = q.answers.select { |a| a.response_class == "answer" }.first
        Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "PRE_PREG.CELL_PHONE"
        answer = q.answers.select { |a| a.response_class == "string" }.first
        Factory(:response, :survey_section_id => survey_section.id, :string_value => "3125557890", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      end
    end
    
    response_set.responses.reload
    response_set.responses.size.should == 3
    
    PrePregnancyOperationalDataExtractor.extract_data(response_set)
    
    person  = Person.find(person.id)
    person.telephones.size.should == 1
    telephone = person.telephones.first
    
    telephone.phone_type.should == cell
    telephone.phone_nbr.should == "3125557890"
    
  end
  
  it "extracts email operational data from the survey responses" do
    person = Factory(:person)
    person.telephones.size.should == 0

    survey = create_pre_pregnancy_survey_with_email_operational_data
    survey_section = survey.sections.first
    response_set = person.start_instrument(survey)
    response_set.responses.size.should == 0
      
    survey_section.questions.each do |q|
      case q.data_export_identifier
      when "PRE_PREG.EMAIL"
        answer = q.answers.select { |a| a.response_class == "string" }.first
        Factory(:response, :survey_section_id => survey_section.id, :string_value => "email@dev.null", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      end
    end
    
    response_set.responses.reload
    response_set.responses.size.should == 1
    
    PrePregnancyOperationalDataExtractor.extract_data(response_set)
    
    person = Person.find(person.id)
    person.emails.size.should == 1
    person.emails.first.email.should == "email@dev.null"
  end
  
  
  
end