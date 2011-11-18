require 'spec_helper'

describe PregnancyScreenerOperationalDataExtractor do

  before(:each) do
    create_missing_in_error_ncs_codes(Instrument)
    create_missing_in_error_ncs_codes(Address)
    create_missing_in_error_ncs_codes(DwellingUnit)
    create_missing_in_error_ncs_codes(Telephone)
    create_missing_in_error_ncs_codes(Email)
    create_missing_in_error_ncs_codes(Participant)
    create_missing_in_error_ncs_codes(PpgDetail)
    Factory(:ncs_code, :list_name => "PERSON_PARTCPNT_RELTNSHP_CL1", :display_text => "Self", :local_code => 1)
  end

  context "extracting person operational data" do

    let(:age_range)      { Factory(:ncs_code, :list_name => "AGE_RANGE_CL1", :display_text => "25-34", :local_code => 3) }
    let(:ethnic_group)   { Factory(:ncs_code, :list_name => "ETHNICITY_CL1", :display_text => "Not Hispanic or Latino", :local_code => 2) }
    let(:language)       { Factory(:ncs_code, :list_name => "LANGUAGE_CL2", :display_text => "English", :local_code => 1) }
    let(:age_eligible)   { Factory(:ncs_code, :list_name => "AGE_ELIGIBLE_CL2", :display_text => "Age-Eligible", :local_code => 1) }
  
    before(:each) do
      @person = Factory(:person)
      @participant = Factory(:participant, :person => @person)
      @survey = create_pregnancy_screener_survey_with_person_operational_data
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
      survey_section = @survey.sections.first
      response_set, instrument = @person.start_instrument(@survey)
      response_set.responses.size.should == 0
      survey_section.questions.each do |q|
        case q.data_export_identifier
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.R_FNAME"
          answer = q.answers.select { |a| a.response_class == "string" }.first
          Factory(:response, :survey_section_id => survey_section.id, :string_value => "Jo", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.R_LNAME"
          answer = q.answers.select { |a| a.response_class == "string" }.first
          Factory(:response, :survey_section_id => survey_section.id, :string_value => "Stafford", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.PERSON_DOB"
          answer = q.answers.select { |a| a.response_class == "date" }.first
          Factory(:response, :survey_section_id => survey_section.id, :datetime_value => Date.parse("01/11/1981"), :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.AGE"
          answer = q.answers.select { |a| a.response_class == "integer" }.first
          Factory(:response, :survey_section_id => survey_section.id, :integer_value => 30, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.AGE_RANGE"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "#{age_range.local_code}" }.first
          Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.ETHNICITY"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "#{ethnic_group.local_code}" }.first
          Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.PERSON_LANG"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "#{language.local_code}" }.first
          Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.PERSON_LANG_OTH"
          ## Do nothing
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.AGE_ELIG"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "#{age_eligible.local_code}" }.first
          Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)        
        end
      end
    
      response_set.responses.reload
      response_set.responses.size.should == 8
    
      PregnancyScreenerOperationalDataExtractor.extract_data(response_set)
    
      person = Person.find(@person.id)
      person.first_name.should == "Jo"
      person.last_name.should == "Stafford"
      person.person_dob.should == "1981-01-11"
      person.age.should == 30
    
      person.age_range.should == age_range
      person.ethnic_group.should == ethnic_group
      person.language.should == language
    
      person.participant.pid_age_eligibility.display_text.should == age_eligible.display_text
      person.participant.pid_age_eligibility.local_code.should == age_eligible.local_code
    end
  
    describe "parsing datetime values" do
      
      it "handles YYYY-MM-DD" do
        entered_dob = "1981-01-11"
        survey_section = @survey.sections.first
        response_set, instrument = @person.start_instrument(@survey)
        response_set.responses.size.should == 0
        survey_section.questions.each do |q|
          case q.data_export_identifier
          when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.PERSON_DOB"
            answer = q.answers.select { |a| a.response_class == "date" }.first
            Factory(:response, :survey_section_id => survey_section.id, :datetime_value => Date.parse(entered_dob), :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
          end
        end

        response_set.responses.reload
        response_set.responses.size.should == 1

        PregnancyScreenerOperationalDataExtractor.extract_data(response_set)

        person = Person.find(@person.id)
        person.person_dob.should == Date.parse(entered_dob).to_s
        person.person_dob_date.should == Date.parse(entered_dob)
      end
      
      it "handles YYYYMMDD"
      
      it "handles MM/DD/YYYY" do
        entered_dob = "01/11/1981"
        survey_section = @survey.sections.first
        response_set, instrument = @person.start_instrument(@survey)
        response_set.responses.size.should == 0
        survey_section.questions.each do |q|
          case q.data_export_identifier
          when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.PERSON_DOB"
            answer = q.answers.select { |a| a.response_class == "date" }.first
            Factory(:response, :survey_section_id => survey_section.id, :datetime_value => Date.parse(entered_dob), :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
          end
        end

        response_set.responses.reload
        response_set.responses.size.should == 1

        PregnancyScreenerOperationalDataExtractor.extract_data(response_set)

        person = Person.find(@person.id)
        person.person_dob.class.should == String
        person.person_dob.should == Date.parse(entered_dob).to_s
        person.person_dob_date.should == Date.parse(entered_dob)
      end
      
      it "handles MM/DD/YY"
      
    end
    
  
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
    
    survey = create_pregnancy_screener_survey_with_address_operational_data
    survey_section = survey.sections.first
    response_set, instrument = person.start_instrument(survey)
    response_set.responses.size.should == 0
    survey_section.questions.each do |q|
      case q.data_export_identifier
      when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.ADDRESS_1"
        answer = q.answers.select { |a| a.response_class == "string" }.first
        Factory(:response, :survey_section_id => survey_section.id, :string_value => "123 Easy St.", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.ADDRESS_2"
        answer = q.answers.select { |a| a.response_class == "string" }.first
        Factory(:response, :survey_section_id => survey_section.id, :string_value => "", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.UNIT"
        answer = q.answers.select { |a| a.response_class == "string" }.first
        Factory(:response, :survey_section_id => survey_section.id, :string_value => "", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.CITY"
        answer = q.answers.select { |a| a.response_class == "string" }.first
        Factory(:response, :survey_section_id => survey_section.id, :string_value => "Chicago", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.STATE"
        answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "#{state.local_code}" }.first
        Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.ZIP"
        answer = q.answers.select { |a| a.response_class == "string" }.first
        Factory(:response, :survey_section_id => survey_section.id, :string_value => "65432", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.ZIP4"
        answer = q.answers.select { |a| a.response_class == "string" }.first
        Factory(:response, :survey_section_id => survey_section.id, :string_value => "1234", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      end
    end
    
    response_set.responses.reload
    response_set.responses.size.should == 7
    
    PregnancyScreenerOperationalDataExtractor.extract_data(response_set)
    
    person  = Person.find(person.id)
    person.addresses.size.should == 1
    address = person.addresses.first
    address.to_s.should == "123 Easy St. Chicago IL 65432-1234"
    
  end


  it "extracts mail address operational data from the survey responses" do
    
    state = Factory(:ncs_code, :list_name => "STATE_CL1", :display_text => "IL", :local_code => 14)
    
    person = Factory(:person)
    person.addresses.size.should == 0
    
    survey = create_pregnancy_screener_survey_with_mail_address_operational_data
    survey_section = survey.sections.first
    response_set, instrument = person.start_instrument(survey)
    response_set.responses.size.should == 0
    survey_section.questions.each do |q|
      case q.data_export_identifier
      when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.MAIL_ADDRESS_1"
        answer = q.answers.select { |a| a.response_class == "string" }.first
        Factory(:response, :survey_section_id => survey_section.id, :string_value => "123 Easy St.", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.MAIL_ADDRESS_2"
        answer = q.answers.select { |a| a.response_class == "string" }.first
        Factory(:response, :survey_section_id => survey_section.id, :string_value => "", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.MAIL_UNIT"
        answer = q.answers.select { |a| a.response_class == "string" }.first
        Factory(:response, :survey_section_id => survey_section.id, :string_value => "", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.MAIL_CITY"
        answer = q.answers.select { |a| a.response_class == "string" }.first
        Factory(:response, :survey_section_id => survey_section.id, :string_value => "Chicago", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.MAIL_STATE"
        answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "#{state.local_code}" }.first
        Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.MAIL_ZIP"
        answer = q.answers.select { |a| a.response_class == "string" }.first
        Factory(:response, :survey_section_id => survey_section.id, :string_value => "65432", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.MAIL_ZIP4"
        answer = q.answers.select { |a| a.response_class == "string" }.first
        Factory(:response, :survey_section_id => survey_section.id, :string_value => "1234", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      end
    end
    
    response_set.responses.reload
    response_set.responses.size.should == 7
    
    PregnancyScreenerOperationalDataExtractor.extract_data(response_set)
    
    person  = Person.find(person.id)
    person.addresses.size.should == 1
    address = person.addresses.first
    address.to_s.should == "123 Easy St. Chicago IL 65432-1234"
    
  end
  
  context "extracting telephone operational data from the survey responses" do
  
    let(:home) { Factory(:ncs_code, :list_name => "PHONE_TYPE_CL1", :display_text => "Home", :local_code => 1) }
    let(:work) { Factory(:ncs_code, :list_name => "PHONE_TYPE_CL1", :display_text => "Work", :local_code => 2) }
    let(:cell) { Factory(:ncs_code, :list_name => "PHONE_TYPE_CL1", :display_text => "Cell", :local_code => 3) }
    let(:frre) { Factory(:ncs_code, :list_name => "PHONE_TYPE_CL1", :display_text => "Friend/Relative", :local_code => 4) }
    let(:fax)  { Factory(:ncs_code, :list_name => "PHONE_TYPE_CL1", :display_text => "Fax", :local_code => 5) }
    let(:oth)  { Factory(:ncs_code, :list_name => "PHONE_TYPE_CL1", :display_text => "Other", :local_code => -5) }
  
    before(:each) do
      @person = Factory(:person)
      @person.telephones.size.should == 0

      @survey = create_pregnancy_screener_survey_with_telephone_operational_data
    end
  
    it "extracts telephone operational data" do
      survey_section = @survey.sections.first
      response_set, instrument = @person.start_instrument(@survey)
      response_set.responses.size.should == 0
      
      survey_section.questions.each do |q|
        case q.data_export_identifier
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.PHONE_NBR"
          answer = q.answers.select { |a| a.response_class == "string" }.first
          Factory(:response, :survey_section_id => survey_section.id, :string_value => "3125551234", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.PHONE_NBR_OTH"
          answer = q.answers.select { |a| a.response_class == "string" }.first
          Factory(:response, :survey_section_id => survey_section.id, :string_value => "", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.PHONE_TYPE"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "#{cell.local_code}" }.first
          Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.PHONE_TYPE_OTH"
          answer = q.answers.select { |a| a.response_class == "string" }.first
          Factory(:response, :survey_section_id => survey_section.id, :string_value => "", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.HOME_PHONE"
          answer = q.answers.select { |a| a.response_class == "string" }.first
          Factory(:response, :survey_section_id => survey_section.id, :string_value => "3125554321", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.CELL_PHONE_2"
          answer = q.answers.select { |a| a.response_class == "answer" }.first
          Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.CELL_PHONE_4"
          answer = q.answers.select { |a| a.response_class == "answer" }.first
          Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.CELL_PHONE"
          answer = q.answers.select { |a| a.response_class == "string" }.first
          Factory(:response, :survey_section_id => survey_section.id, :string_value => "3125557890", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
        end
      end
    
      response_set.responses.reload
      response_set.responses.size.should == 8
    
      PregnancyScreenerOperationalDataExtractor.extract_data(response_set)
    
      person  = Person.find(@person.id)
      person.telephones.size.should == 3
      person.telephones.each do |t|
        t.phone_type.should_not be_nil
        t.phone_nbr[0,6].should == "312555"
      end
    
    end
    
    describe "handling various telephone formats" do

      it "handles xxx.xxx.xxxx" do
        survey_section = @survey.sections.first
        response_set, instrument = @person.start_instrument(@survey)
        response_set.responses.size.should == 0
      
        survey_section.questions.each do |q|
          case q.data_export_identifier
          when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.PHONE_NBR"
            answer = q.answers.select { |a| a.response_class == "string" }.first
            Factory(:response, :survey_section_id => survey_section.id, :string_value => "312.555.1234", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
          end
        end
    
        response_set.responses.reload
        response_set.responses.size.should == 1
    
        PregnancyScreenerOperationalDataExtractor.extract_data(response_set)
    
        person  = Person.find(@person.id)
        person.telephones.size.should == 1
        person.telephones.each do |t|
          t.phone_type.should_not be_nil
          t.phone_nbr.should == "3125551234"
        end
        
      end
      
      it "handles (xxx) xxx-xxxx" do
        survey_section = @survey.sections.first
        response_set, instrument = @person.start_instrument(@survey)
        response_set.responses.size.should == 0
      
        survey_section.questions.each do |q|
          case q.data_export_identifier
          when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.PHONE_NBR"
            answer = q.answers.select { |a| a.response_class == "string" }.first
            Factory(:response, :survey_section_id => survey_section.id, :string_value => "(312) 555-1234", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
          end
        end
    
        response_set.responses.reload
        response_set.responses.size.should == 1
    
        PregnancyScreenerOperationalDataExtractor.extract_data(response_set)
    
        person  = Person.find(@person.id)
        person.telephones.size.should == 1
        person.telephones.each do |t|
          t.phone_type.should_not be_nil
          t.phone_nbr.should == "3125551234"
        end
        
      end
      
      it "handles (xxx) xxxxxxx" do
        survey_section = @survey.sections.first
        response_set, instrument = @person.start_instrument(@survey)
        response_set.responses.size.should == 0
      
        survey_section.questions.each do |q|
          case q.data_export_identifier
          when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.PHONE_NBR"
            answer = q.answers.select { |a| a.response_class == "string" }.first
            Factory(:response, :survey_section_id => survey_section.id, :string_value => "(312) 5551234", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
          end
        end
    
        response_set.responses.reload
        response_set.responses.size.should == 1
    
        PregnancyScreenerOperationalDataExtractor.extract_data(response_set)
    
        person  = Person.find(@person.id)
        person.telephones.size.should == 1
        person.telephones.each do |t|
          t.phone_type.should_not be_nil
          t.phone_nbr.should == "3125551234"
        end
        
      end
      
      it "handles xxx-xxx-xxxx" do
        survey_section = @survey.sections.first
        response_set, instrument = @person.start_instrument(@survey)
        response_set.responses.size.should == 0
      
        survey_section.questions.each do |q|
          case q.data_export_identifier
          when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.PHONE_NBR"
            answer = q.answers.select { |a| a.response_class == "string" }.first
            Factory(:response, :survey_section_id => survey_section.id, :string_value => "312-555-1234", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
          end
        end
    
        response_set.responses.reload
        response_set.responses.size.should == 1
    
        PregnancyScreenerOperationalDataExtractor.extract_data(response_set)
    
        person  = Person.find(@person.id)
        person.telephones.size.should == 1
        person.telephones.each do |t|
          t.phone_type.should_not be_nil
          t.phone_nbr.should == "3125551234"
        end
      end
      
    end

  end
  
  it "extracts email information from the survey responses" do
    
    home = Factory(:ncs_code, :list_name => "EMAIL_TYPE_CL1", :display_text => "Personal", :local_code => 1)
    work = Factory(:ncs_code, :list_name => "EMAIL_TYPE_CL1", :display_text => "Work", :local_code => 2)

    person = Factory(:person)
    person.emails.size.should == 0

    survey = create_pregnancy_screener_survey_with_email_operational_data
    survey_section = survey.sections.first
    response_set, instrument = person.start_instrument(survey)
    response_set.responses.size.should == 0

    survey_section.questions.each do |q|
      case q.data_export_identifier
      when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.EMAIL"
        answer = q.answers.select { |a| a.response_class == "string" }.first
        Factory(:response, :survey_section_id => survey_section.id, :string_value => "email@dev.null", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.EMAIL_TYPE"
        answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "#{home.local_code}" }.first
        Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      end
    end
    
    response_set.responses.reload
    response_set.responses.size.should == 2
    
    PregnancyScreenerOperationalDataExtractor.extract_data(response_set)
    
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
    
    survey = create_pregnancy_screener_survey_with_ppg_detail_operational_data
    survey_section = survey.sections.first
    response_set, instrument = person.start_instrument(survey)
    response_set.responses.size.should == 0
    
    survey_section.questions.each do |q|
      case q.data_export_identifier
      when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.PREGNANT"
        answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "#{ppg1.local_code}" }.first
        Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.ORIG_DUE_DATE"
        answer = q.answers.select { |a| a.response_class == "date" }.first
        Factory(:response, :survey_section_id => survey_section.id, :datetime_value => "2011-12-25", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      end
    end
    
    response_set.responses.reload
    response_set.responses.size.should == 2
    
    PregnancyScreenerOperationalDataExtractor.extract_data(response_set)
    
    person  = Person.find(person.id)
    participant = person.participant
    participant.ppg_details.size.should == 1
    participant.ppg_details.first.ppg_first.local_code.should == 1
    participant.ppg_status.local_code.should == 1
    participant.due_date.should == Date.parse("2011-12-25")
    
  end

  it "sets the ppg detail ppg status to 2 if the person responds that they are trying to become pregnant" do
    
    person = Factory(:person)
    participant = Factory(:participant, :person => person)
    ppl = Factory(:participant_person_link, :participant => participant, :person => person)
    
    ppg2 = Factory(:ncs_code, :list_name => "PPG_STATUS_CL2", :display_text => "PPG Group 2", :local_code => 2)
    
    survey = create_pregnancy_screener_survey_with_ppg_detail_operational_data
    survey_section = survey.sections.first
    response_set, instrument = person.start_instrument(survey)
    response_set.responses.size.should == 0
    
    survey_section.questions.each do |q|
      case q.data_export_identifier
      when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.TRYING"
        answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "1" }.first
        Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      end
    end
    
    response_set.responses.reload
    response_set.responses.size.should == 1
    
    PregnancyScreenerOperationalDataExtractor.extract_data(response_set)
    
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
    
    survey = create_pregnancy_screener_survey_with_ppg_detail_operational_data
    survey_section = survey.sections.first
    response_set, instrument = person.start_instrument(survey)
    response_set.responses.size.should == 0
    
    survey_section.questions.each do |q|
      case q.data_export_identifier
      when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.HYSTER"
        answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "1" }.first
        Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
      end
    end
    
    response_set.responses.reload
    response_set.responses.size.should == 1
    
    PregnancyScreenerOperationalDataExtractor.extract_data(response_set)
    
    person  = Person.find(person.id)
    participant = person.participant
    participant.ppg_details.size.should == 1
    participant.ppg_details.first.ppg_first.local_code.should == 5
    participant.ppg_status.local_code.should == 5
    participant.due_date.should be_nil
  end

  context "determining the due date of a pregnant woman" do
    
    let(:ppg1) { Factory(:ncs_code, :list_name => "PPG_STATUS_CL2", :display_text => "PPG Group 1", :local_code => 1) }
  
    before(:each) do
      @person = Factory(:person)
      @participant = Factory(:participant, :person => @person)

      @survey = create_pregnancy_screener_survey_to_determine_due_date
      
      @survey_section = @survey.sections.first
      @response_set, @instrument = @person.start_instrument(@survey)
      @response_set.responses.size.should == 0
    end

    
    it "sets the due date to the date provided by the participant" do
    
      due_date = "2012-02-29"

      @survey_section.questions.each do |q|
        case q.data_export_identifier
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.PREGNANT"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "#{ppg1.local_code}" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.ORIG_DUE_DATE"
          answer = q.answers.select { |a| a.response_class == "date" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :datetime_value => due_date, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        end
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 2

      PregnancyScreenerOperationalDataExtractor.extract_data(@response_set)

      person  = Person.find(@person.id)
      participant = person.participant
      participant.due_date.should == Date.parse(due_date)
      
    end
    
    # CALCULATE DUE DATE FROM THE FIRST DATE OF LAST MENSTRUAL PERIOD AND SET ORIG_DUE_DATE = DATE_PERIOD + 280 DAYS
    it "calculates the due date based on the date of the last menstrual period" do

      last_period = 20.weeks.ago

      @survey_section.questions.each do |q|
        case q.data_export_identifier
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.PREGNANT"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "#{ppg1.local_code}" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.ORIG_DUE_DATE"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "neg_2" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.DATE_PERIOD"
          answer = q.answers.select { |a| a.response_class == "date" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :datetime_value => last_period, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        end
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 3

      PregnancyScreenerOperationalDataExtractor.extract_data(@response_set)

      person  = Person.find(@person.id)
      participant = person.participant
      participant.due_date.should == (last_period + 280.days).to_date

    end
    
    # CALCULATE ORIG_DUE_DATE =TODAY’S DATE + 280 DAYS – WEEKS_PREG * 7
    it "calculates the due date based on the number of weeks pregnant" do
      
      weeks_pregnant = 8
      
      @survey_section.questions.each do |q|
        case q.data_export_identifier
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.PREGNANT"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "#{ppg1.local_code}" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.ORIG_DUE_DATE"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "neg_2" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.DATE_PERIOD"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "neg_2" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.WEEKS_PREG"
          answer = q.answers.select { |a| a.response_class == "integer" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :integer_value => weeks_pregnant, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        end
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 4

      PregnancyScreenerOperationalDataExtractor.extract_data(@response_set)

      person  = Person.find(@person.id)
      participant = person.participant
      participant.due_date.should == ((Date.today + 280.days) - (weeks_pregnant * 7)).to_date
      
    end
    
    # CALCULATE DUE DATE AS FROM NUMBER OF MONTHS PREGNANT WHERE ORIG_DUE_DATE =TODAY’S DATE + 280 DAYS – MONTH_PREG * 30 - 15
    it "calculates the due date based on the number of months pregnant" do
      months_pregnant = 4
      
      @survey_section.questions.each do |q|
        case q.data_export_identifier
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.PREGNANT"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "#{ppg1.local_code}" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.ORIG_DUE_DATE"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "neg_2" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.DATE_PERIOD"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "neg_2" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.WEEKS_PREG"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "neg_2" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.MONTH_PREG"
          answer = q.answers.select { |a| a.response_class == "integer" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :integer_value => months_pregnant, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        end
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 5

      PregnancyScreenerOperationalDataExtractor.extract_data(@response_set)

      person  = Person.find(@person.id)
      participant = person.participant
      participant.due_date.should == ((Date.today + 280.days) - ((months_pregnant * 30) - 15)).to_date
      
    end
    
    # 1ST TRIMESTER:      ORIG_DUE_DATE = TODAY’S DATE + (280 DAYS – 46 DAYS).
    # 2ND TRIMESTER:      ORIG_DUE_DATE = TODAY’S DATE + (280 DAYS – 140 DAYS).
    # 3RD TRIMESTER:      ORIG_DUE_DATE = TODAY’S DATE + (280 DAYS – 235 DAYS).
    # DON’T KNOW/REFUSED: ORIG_DUE_DATE = TODAY’S DATE + (280 DAYS – 140 DAYS)
    it "calculates the due date based on the 1st trimester" do
      @survey_section.questions.each do |q|
        case q.data_export_identifier
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.PREGNANT"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "#{ppg1.local_code}" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.ORIG_DUE_DATE"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "neg_2" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.DATE_PERIOD"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "neg_2" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.WEEKS_PREG"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "neg_2" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.MONTH_PREG"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "neg_2" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.TRIMESTER"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "1" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        end
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 6

      PregnancyScreenerOperationalDataExtractor.extract_data(@response_set)

      person  = Person.find(@person.id)
      participant = person.participant
      participant.due_date.should == ((Date.today + 280.days) - (46.days)).to_date
      
    end
    
    it "calculates the due date based on the 2nd trimester" do
      @survey_section.questions.each do |q|
        case q.data_export_identifier
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.PREGNANT"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "#{ppg1.local_code}" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.ORIG_DUE_DATE"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "neg_2" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.DATE_PERIOD"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "neg_2" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.WEEKS_PREG"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "neg_2" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.MONTH_PREG"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "neg_2" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.TRIMESTER"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "2" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        end
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 6

      PregnancyScreenerOperationalDataExtractor.extract_data(@response_set)

      person  = Person.find(@person.id)
      participant = person.participant
      participant.due_date.should == ((Date.today + 280.days) - (140.days)).to_date
    end

    it "calculates the due date based on the 3rd trimester" do
      @survey_section.questions.each do |q|
        case q.data_export_identifier
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.PREGNANT"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "#{ppg1.local_code}" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.ORIG_DUE_DATE"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "neg_2" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.DATE_PERIOD"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "neg_2" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.WEEKS_PREG"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "neg_2" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.MONTH_PREG"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "neg_2" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.TRIMESTER"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "3" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        end
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 6

      PregnancyScreenerOperationalDataExtractor.extract_data(@response_set)

      person  = Person.find(@person.id)
      participant = person.participant
      participant.due_date.should == ((Date.today + 280.days) - (235.days)).to_date
    end
    
    it "calculates the due date when refused" do
      @survey_section.questions.each do |q|
        case q.data_export_identifier
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.PREGNANT"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "#{ppg1.local_code}" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.ORIG_DUE_DATE"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "neg_2" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.DATE_PERIOD"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "neg_2" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.WEEKS_PREG"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "neg_2" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.MONTH_PREG"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "neg_2" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.TRIMESTER"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "neg_2" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        end
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 6

      PregnancyScreenerOperationalDataExtractor.extract_data(@response_set)

      person  = Person.find(@person.id)
      participant = person.participant
      participant.due_date.should == ((Date.today + 280.days) - (140.days)).to_date
    end
    
    it "calculates the due date when don't know" do
      @survey_section.questions.each do |q|
        case q.data_export_identifier
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.PREGNANT"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "#{ppg1.local_code}" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.ORIG_DUE_DATE"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "neg_2" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.DATE_PERIOD"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "neg_2" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.WEEKS_PREG"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "neg_2" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.MONTH_PREG"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "neg_2" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.TRIMESTER"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "neg_1" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => @response_set.id)
        end
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 6

      PregnancyScreenerOperationalDataExtractor.extract_data(@response_set)

      person  = Person.find(@person.id)
      participant = person.participant
      participant.due_date.should == ((Date.today + 280.days) - (140.days)).to_date
    end
    
  end

end