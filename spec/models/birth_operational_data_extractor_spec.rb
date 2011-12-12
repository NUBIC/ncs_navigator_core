require 'spec_helper'

describe BirthOperationalDataExtractor do

  before(:each) do
    create_missing_in_error_ncs_codes(DwellingUnit)
    create_missing_in_error_ncs_codes(Instrument)
    create_missing_in_error_ncs_codes(Address)
    create_missing_in_error_ncs_codes(Telephone)
    create_missing_in_error_ncs_codes(Participant)
    create_missing_in_error_ncs_codes(Person)
    Factory(:ncs_code, :list_name => "PERSON_PARTCPNT_RELTNSHP_CL1", :display_text => "Self", :local_code => 1)

    Factory(:ncs_code, :list_name => "PERSON_PARTCPNT_RELTNSHP_CL1", :display_text => "Biological Mother", :local_code => 2)
    Factory(:ncs_code, :list_name => "PERSON_PARTCPNT_RELTNSHP_CL1", :display_text => "Child", :local_code => 8)
  end

  context "creating a new person record for the child" do

    before(:each) do
      Factory(:ncs_code, :list_name => "PERSON_PARTCPNT_RELTNSHP_CL1", :display_text => "Participant/Self", :local_code => 1)
      Factory(:ncs_code, :list_name => "PERSON_PARTCPNT_RELTNSHP_CL1", :display_text => "Child", :local_code => 8)

      @male   = Factory(:ncs_code, :list_name => "GENDER_CL1", :display_text => "Male", :local_code => 1)
      @female = Factory(:ncs_code, :list_name => "GENDER_CL1", :display_text => "Female", :local_code => 2)

      @person = Factory(:person)
      @participant = Factory(:participant, :person => @person)
      Factory(:ppg_detail, :participant => @participant)

      @survey = create_pregnancy_visit_1_survey_with_contact_operational_data
      @survey_section = @survey.sections.first
      @response_set, @instrument = @person.start_instrument(@survey)

      @response_set.responses.size.should == 0
      @participant.participant_person_links.size.should == 1
    end

    it "creates a new person (Child) record and associates it with the particpant" do

      survey = create_birth_survey_with_child_operational_data
      survey_section = survey.sections.first
      response_set, instrument = @person.start_instrument(survey)

      response_set.responses.size.should == 0

      survey_section.questions.each do |q|
        case q.data_export_identifier
        when "#{BirthOperationalDataExtractor::BABY_NAME_PREFIX}.BABY_FNAME"
          answer = q.answers.select { |a| a.response_class == "string" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :string_value => "Mary", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
        when "#{BirthOperationalDataExtractor::BABY_NAME_PREFIX}.BABY_MNAME"
          answer = q.answers.select { |a| a.response_class == "string" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :string_value => "Jane", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
        when "#{BirthOperationalDataExtractor::BABY_NAME_PREFIX}.BABY_LNAME"
          answer = q.answers.select { |a| a.response_class == "string" }.first
          Factory(:response, :survey_section_id => @survey_section.id, :string_value => "Williams", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
        when "#{BirthOperationalDataExtractor::BABY_NAME_PREFIX}.BABY_SEX"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "#{@female.local_code}" }.first
          Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
        end
      end

      response_set.responses.reload
      response_set.responses.size.should == 4

      BirthOperationalDataExtractor.extract_data(response_set)

      person  = Person.find(@person.id)
      participant = person.participant
      participant.participant_person_links.size.should == 2
      participant.children.should_not be_nil
      child = participant.children.first
      child.first_name.should == "Mary"
      child.last_name.should == "Williams"
      child.sex.should == @female

      # child.mother.should == person - will not know until child is a participant
    end

  end

  context "extracting tracing operational data" do

    let(:home) { Factory(:ncs_code, :list_name => "PHONE_TYPE_CL1", :display_text => "Home", :local_code => 1) }
    let(:work) { Factory(:ncs_code, :list_name => "PHONE_TYPE_CL1", :display_text => "Work", :local_code => 2) }
    let(:cell) { Factory(:ncs_code, :list_name => "PHONE_TYPE_CL1", :display_text => "Cell", :local_code => 3) }
    let(:frre) { Factory(:ncs_code, :list_name => "PHONE_TYPE_CL1", :display_text => "Friend/Relative", :local_code => 4) }
    let(:fax)  { Factory(:ncs_code, :list_name => "PHONE_TYPE_CL1", :display_text => "Fax", :local_code => 5) }
    let(:oth)  { Factory(:ncs_code, :list_name => "PHONE_TYPE_CL1", :display_text => "Other", :local_code => -5) }

    before(:each) do
      @person = Factory(:person)
      @participant = Factory(:participant, :person => @person)
      @survey = create_birth_survey_with_tracing_operational_data
    end

    it "extracts person operational data from the survey responses" do
      survey_section = @survey.sections.first
      response_set, instrument = @person.start_instrument(@survey)
      response_set.responses.size.should == 0
      survey_section.questions.each do |q|
        case q.data_export_identifier
        when "#{BirthOperationalDataExtractor::BIRTH_VISIT_PREFIX}.R_FNAME"
          answer = q.answers.select { |a| a.response_class == "string" }.first
          Factory(:response, :survey_section_id => survey_section.id, :string_value => "Jocelyn", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
        when "#{BirthOperationalDataExtractor::BIRTH_VISIT_PREFIX}.R_LNAME"
          answer = q.answers.select { |a| a.response_class == "string" }.first
          Factory(:response, :survey_section_id => survey_section.id, :string_value => "Goldsmith", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
        end
      end

      response_set.responses.reload
      response_set.responses.size.should == 2

      BirthOperationalDataExtractor.extract_data(response_set)

      person = Person.find(@person.id)
      person.first_name.should == "Jocelyn"
      person.last_name.should == "Goldsmith"
    end

    it "extracts mailing address data" do

      state = Factory(:ncs_code, :list_name => "STATE_CL1", :display_text => "IL", :local_code => 14)
      Factory(:ncs_code, :list_name => "ADDRESS_CATEGORY_CL1", :display_text => "Home", :local_code => 1)
      Factory(:ncs_code, :list_name => "ADDRESS_CATEGORY_CL1", :display_text => "Mailing", :local_code => 4)

      @person.addresses.size.should == 0

      survey_section = @survey.sections.first
      response_set, instrument = @person.start_instrument(@survey)
      response_set.responses.size.should == 0
      survey_section.questions.each do |q|
        case q.data_export_identifier
        when "#{BirthOperationalDataExtractor::BIRTH_VISIT_PREFIX}.MAIL_ADDRESS1"
          answer = q.answers.select { |a| a.response_class == "string" }.first
          Factory(:response, :survey_section_id => survey_section.id, :string_value => "123 Easy St.", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
        when "#{BirthOperationalDataExtractor::BIRTH_VISIT_PREFIX}.MAIL_ADDRESS2"
          answer = q.answers.select { |a| a.response_class == "string" }.first
          Factory(:response, :survey_section_id => survey_section.id, :string_value => "", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
        when "#{BirthOperationalDataExtractor::BIRTH_VISIT_PREFIX}.MAIL_UNIT"
          answer = q.answers.select { |a| a.response_class == "string" }.first
          Factory(:response, :survey_section_id => survey_section.id, :string_value => "", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
        when "#{BirthOperationalDataExtractor::BIRTH_VISIT_PREFIX}.MAIL_CITY"
          answer = q.answers.select { |a| a.response_class == "string" }.first
          Factory(:response, :survey_section_id => survey_section.id, :string_value => "Chicago", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
        when "#{BirthOperationalDataExtractor::BIRTH_VISIT_PREFIX}.MAIL_STATE"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "#{state.local_code}" }.first
          Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
        when "#{BirthOperationalDataExtractor::BIRTH_VISIT_PREFIX}.MAIL_ZIP"
          answer = q.answers.select { |a| a.response_class == "string" }.first
          Factory(:response, :survey_section_id => survey_section.id, :string_value => "65432", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
        when "#{BirthOperationalDataExtractor::BIRTH_VISIT_PREFIX}.MAIL_ZIP4"
          answer = q.answers.select { |a| a.response_class == "string" }.first
          Factory(:response, :survey_section_id => survey_section.id, :string_value => "1234", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
        end
      end

      response_set.responses.reload
      response_set.responses.size.should == 7

      BirthOperationalDataExtractor.extract_data(response_set)

      person  = Person.find(@person.id)
      person.addresses.size.should == 1
      address = person.addresses.first
      address.to_s.should == "123 Easy St. Chicago IL 65432-1234"
    end

    it "extracts telephone operational data" do
      survey_section = @survey.sections.first
      response_set, instrument = @person.start_instrument(@survey)
      response_set.responses.size.should == 0
      @person.telephones.size.should == 0

      survey_section.questions.each do |q|
        case q.data_export_identifier
        when "#{BirthOperationalDataExtractor::BIRTH_VISIT_PREFIX}.PHONE_NBR"
          answer = q.answers.select { |a| a.response_class == "string" }.first
          Factory(:response, :survey_section_id => survey_section.id, :string_value => "3125551234", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
        when "#{BirthOperationalDataExtractor::BIRTH_VISIT_PREFIX}.PHONE_NBR_OTH"
          answer = q.answers.select { |a| a.response_class == "string" }.first
          Factory(:response, :survey_section_id => survey_section.id, :string_value => "", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
        when "#{BirthOperationalDataExtractor::BIRTH_VISIT_PREFIX}.PHONE_TYPE"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "#{cell.local_code}" }.first
          Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
        when "#{BirthOperationalDataExtractor::BIRTH_VISIT_PREFIX}.PHONE_TYPE_OTH"
          answer = q.answers.select { |a| a.response_class == "string" }.first
          Factory(:response, :survey_section_id => survey_section.id, :string_value => "", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
        when "#{BirthOperationalDataExtractor::BIRTH_VISIT_PREFIX}.HOME_PHONE"
          answer = q.answers.select { |a| a.response_class == "string" }.first
          Factory(:response, :survey_section_id => survey_section.id, :string_value => "3125554321", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
        when "#{BirthOperationalDataExtractor::BIRTH_VISIT_PREFIX}.CELL_PHONE_2"
          answer = q.answers.select { |a| a.response_class == "answer" }.first
          Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
        when "#{BirthOperationalDataExtractor::BIRTH_VISIT_PREFIX}.CELL_PHONE_4"
          answer = q.answers.select { |a| a.response_class == "answer" }.first
          Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
        when "#{BirthOperationalDataExtractor::BIRTH_VISIT_PREFIX}.CELL_PHONE"
          answer = q.answers.select { |a| a.response_class == "string" }.first
          Factory(:response, :survey_section_id => survey_section.id, :string_value => "3125557890", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
        end
      end

      response_set.responses.reload
      response_set.responses.size.should == 8

      BirthOperationalDataExtractor.extract_data(response_set)

      person  = Person.find(@person.id)
      person.telephones.size.should == 3
      person.telephones.each do |t|
        t.phone_type.should_not be_nil
        t.phone_nbr[0,6].should == "312555"
      end
    end

    it "extracts email information from the survey responses" do

      home = Factory(:ncs_code, :list_name => "EMAIL_TYPE_CL1", :display_text => "Personal", :local_code => 1)
      work = Factory(:ncs_code, :list_name => "EMAIL_TYPE_CL1", :display_text => "Work", :local_code => 2)

      @person.emails.size.should == 0

      survey_section = @survey.sections.first
      response_set, instrument = @person.start_instrument(@survey)
      response_set.responses.size.should == 0

      survey_section.questions.each do |q|
        case q.data_export_identifier
        when "#{BirthOperationalDataExtractor::BIRTH_VISIT_PREFIX}.EMAIL"
          answer = q.answers.select { |a| a.response_class == "string" }.first
          Factory(:response, :survey_section_id => survey_section.id, :string_value => "email@dev.null", :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
        when "#{BirthOperationalDataExtractor::BIRTH_VISIT_PREFIX}.EMAIL_TYPE"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "#{home.local_code}" }.first
          Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
        end
      end

      response_set.responses.reload
      response_set.responses.size.should == 2

      BirthOperationalDataExtractor.extract_data(response_set)

      person  = Person.find(@person.id)
      person.emails.size.should == 1
      person.emails.first.email.should == "email@dev.null"
      person.emails.first.email_type.local_code.should == 1

    end


  end

end
