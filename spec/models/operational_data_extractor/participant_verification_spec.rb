# -*- coding: utf-8 -*-


require 'spec_helper'

describe OperationalDataExtractor::ParticipantVerification do
  include SurveyCompletion

  context "child records" do
    before(:each) do
      @male   = NcsCode.for_list_name_and_local_code("GENDER_CL1", 1)
      @female = NcsCode.for_list_name_and_local_code("GENDER_CL1", 2)
      @child_type = NcsCode.for_list_name_and_local_code("PARTICIPANT_TYPE_CL1", 6)

      @person = Factory(:person)
      @participant = Factory(:participant)
      @participant.person = @person
      Factory(:ppg_detail, :participant => @participant)

      @child_participant = @participant.create_child_person_and_participant!(
        {:first_name => "child_fname", :last_name => "child_lname"})

      @participant.participant_person_links.size.should == 1
      @participant.save!
    end

    it "updates the person (Child) record" do
      survey = create_participant_verification_survey
      response_set, instrument = prepare_instrument(@person, @child_participant, survey)

      take_survey(survey, response_set) do |a|
        a.str "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_PREFIX}.C_FNAME", 'Baby'
        a.str "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_PREFIX}.C_LNAME", 'James'
        a.date "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_PREFIX}.CHILD_DOB", '01/01/2013'
      end

      response_set.responses.reload
      response_set.responses.size.should == 3

      OperationalDataExtractor::ParticipantVerification.extract_data(response_set)

      mother = Person.find(@person.id)
      participant = mother.participant
      participant.participant_person_links.size.should == 2
      participant.children.should_not be_nil

      child = participant.children.first
      child.should == @child_participant.person

      child.first_name.should == "Baby"
      child.last_name.should == "James"
      child.person_dob.should == '2013-01-01'

      child.participant.should_not be_nil
      child.participant.should == @child_participant
      child.participant.mother.should == mother
      child.participant.mother.participant.should == participant
      child.participant.p_type.should == @child_type
      participant.children.should include(child)
    end

    it "creates an address record and associates it with the child" do
      state = NcsCode.for_list_name_and_local_code("STATE_CL1", 14)

      survey = create_participant_verification_survey
      response_set, instrument = prepare_instrument(@person, @child_participant, survey)

      take_survey(survey, response_set) do |a|
        a.str "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_PREFIX}.C_FNAME", 'Baby'
        a.str "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_PREFIX}.C_LNAME", 'James'
        a.str "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_PREFIX}.C_ADDRESS_1", '123 Easy St.'
        a.str "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_PREFIX}.C_ADDRESS_2", ''
        a.str "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_PREFIX}.C_CITY", 'Chicago'
        a.choice "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_PREFIX}.C_STATE", state
        a.str "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_PREFIX}.C_ZIP", '65432'
        a.str "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_PREFIX}.C_ZIP4", '1234'

      end

      response_set.responses.reload
      response_set.responses.size.should == 8

      OperationalDataExtractor::ParticipantVerification.extract_data(response_set)

      person  = Person.find(@person.id)
      participant = person.participant
      participant.children.should_not be_nil
      child = participant.children.first

      child.addresses.should_not be_empty
      child.primary_address.to_s.should == "123 Easy St. Chicago, ILLINOIS 65432-1234"
    end

    it "creates a 2ndary address record and associates it with the child" do
      state = NcsCode.for_list_name_and_local_code("STATE_CL1", 14)

      survey = create_participant_verification_survey
      response_set, instrument = prepare_instrument(@person, @child_participant, survey)

      take_survey(survey, response_set) do |a|
        a.str "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_PREFIX}.C_FNAME", 'Baby'
        a.str "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_PREFIX}.C_LNAME", 'James'
        a.str "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_PREFIX}.S_ADDRESS_1", '444 Easy St.'
        a.str "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_PREFIX}.S_ADDRESS_2", 'Apt 2D'
        a.str "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_PREFIX}.S_CITY", 'Chicago'
        a.choice "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_PREFIX}.S_STATE", state
        a.str "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_PREFIX}.S_ZIP", '65432'
        a.str "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_PREFIX}.S_ZIP4", '6789'

      end

      response_set.responses.reload
      response_set.responses.size.should == 8

      OperationalDataExtractor::ParticipantVerification.extract_data(response_set)

      person  = Person.find(@person.id)
      participant = person.participant
      participant.participant_person_links.size.should == 2
      child = participant.children.first

      child.addresses.should_not be_empty
      child.primary_address.to_s.should be_blank
      child.addresses.first.to_s.should == "444 Easy St. Apt 2D Chicago, ILLINOIS 65432-6789"
    end

    it "creates a telephone record and associates it with the child" do
      state = NcsCode.for_list_name_and_local_code("STATE_CL1", 14)

      survey = create_participant_verification_survey
      response_set, instrument = prepare_instrument(@person, @child_participant, survey)

      take_survey(survey, response_set) do |a|
        a.str "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_PREFIX}.C_FNAME", 'Baby'
        a.str "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_PREFIX}.C_LNAME", 'James'
        a.str "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_PREFIX}.PA_PHONE", '312-555-1212'
      end

      response_set.responses.reload
      response_set.responses.size.should == 3

      OperationalDataExtractor::ParticipantVerification.extract_data(response_set)

      person  = Person.find(@person.id)
      participant = person.participant
      participant.participant_person_links.size.should == 2
      participant.children.should_not be_nil
      child = participant.children.first

      child.telephones.should_not be_empty
      child.primary_home_phone.to_s.should == '3125551212'
    end

    it "creates a 2ndary telephone record and associates it with the child" do
      state = NcsCode.for_list_name_and_local_code("STATE_CL1", 14)

      survey = create_participant_verification_survey
      response_set, instrument = prepare_instrument(@person, @child_participant, survey)

      take_survey(survey, response_set) do |a|
        a.str "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_PREFIX}.C_FNAME", 'Baby'
        a.str "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_PREFIX}.C_LNAME", 'James'
        a.str "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_PREFIX}.SA_PHONE", '312-555-4444'
      end

      response_set.responses.reload
      response_set.responses.size.should == 3

      OperationalDataExtractor::ParticipantVerification.extract_data(response_set)

      person  = Person.find(@person.id)
      participant = person.participant
      participant.participant_person_links.size.should == 2
      participant.children.should_not be_nil
      child = participant.children.first

      child.telephones.should_not be_empty
      child.primary_home_phone.to_s.should be_blank
      child.telephones.first.to_s.should == '3125554444'
    end
  end


  context "extracting person operational data" do

    before(:each) do
      @person = Factory(:person, :first_name => nil, :last_name => nil, :middle_name => nil, :person_dob => nil)
      @participant = Factory(:participant)
      @participant.person = @person
      @survey = create_participant_verification_survey
    end

    it "extracts person operational data from the survey responses" do
      response_set, instrument = prepare_instrument(@person, @participant, @survey)
      response_set.save!

      take_survey(@survey, response_set) do |a|
        a.str "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_PREFIX}.R_FNAME", 'Jo'
        a.str "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_PREFIX}.R_MNAME", 'Anna'
        a.str "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_PREFIX}.R_LNAME", 'Stafford'
        a.str "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_PREFIX}.MAIDEN_NAME", 'Hitler'
        a.date "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_PREFIX}.PERSON_DOB", '01/01/1981'
      end

      response_set.responses.reload
      response_set.responses.size.should == 5

      OperationalDataExtractor::ParticipantVerification.extract_data(response_set)

      person = Person.find(@person.id)
      person.first_name.should == "Jo"
      person.middle_name.should == "Anna"
      person.last_name.should == "Stafford"
      person.maiden_name.should == "Hitler"
      person.person_dob.should == "1981-01-01"
    end
  end
end