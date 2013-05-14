# -*- coding: utf-8 -*-


require 'spec_helper'

describe OperationalDataExtractor::ParticipantVerification do
  include SurveyCompletion

  let(:state) { NcsCode.for_list_name_and_local_code("STATE_CL1", 14) }
  let(:survey) { create_participant_verification_survey }

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
      response_set, instrument = prepare_instrument(@person, @child_participant, survey)

      take_survey(survey, response_set) do |r|
        r.a "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_CHILD_PREFIX}.C_FNAME", 'Baby'
        r.a "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_CHILD_PREFIX}.C_LNAME", 'James'
        r.a "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_CHILD_PREFIX}.CHILD_DOB", '01/01/2013'
        r.a "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_CHILD_PREFIX}.CHILD_SEX", @female
      end

      response_set.responses.reload
      response_set.responses.size.should == 4

      OperationalDataExtractor::ParticipantVerification.new(response_set).extract_data

      mother = Person.find(@person.id)
      participant = mother.participant
      participant.participant_person_links.size.should == 2
      participant.children.should_not be_nil

      child = participant.children.first
      child.should == @child_participant.person

      child.first_name.should == "Baby"
      child.last_name.should == "James"
      child.person_dob.should == '2013-01-01'
      child.sex.should == @female

      child.participant.should_not be_nil
      child.participant.should == @child_participant
      child.participant.mother.should == mother
      child.participant.mother.participant.should == participant
      child.participant.p_type.should == @child_type
      participant.children.should include(child)
    end

    it "creates an address record and associates it with the child" do
      response_set, instrument = prepare_instrument(@person, @child_participant, survey)

      take_survey(survey, response_set) do |r|
        r.a "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_CHILD_PREFIX}.C_FNAME", 'Baby'
        r.a "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_CHILD_PREFIX}.C_LNAME", 'James'
        r.a "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_PREFIX}.C_ADDRESS_1", '123 Easy St.'
        r.a "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_PREFIX}.C_ADDRESS_2", ''
        r.a "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_PREFIX}.C_CITY", 'Chicago'
        r.a "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_PREFIX}.C_STATE", state
        r.a "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_PREFIX}.C_ZIP", '65432'
        r.a "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_PREFIX}.C_ZIP4", '1234'
      end

      response_set.responses.reload
      response_set.responses.size.should == 8

      OperationalDataExtractor::ParticipantVerification.new(response_set).extract_data

      person  = Person.find(@person.id)
      participant = person.participant
      participant.children.should_not be_nil
      child = participant.children.first

      child.addresses.should_not be_empty
      child.primary_address.to_s.should == "123 Easy St. Chicago, Illinois 65432-1234"
    end

    it "creates a 2ndary address record and associates it with the child" do
      response_set, instrument = prepare_instrument(@person, @child_participant, survey)

      take_survey(survey, response_set) do |r|
        r.a "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_CHILD_PREFIX}.C_FNAME", 'Baby'
        r.a "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_CHILD_PREFIX}.C_LNAME", 'James'
        r.a "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_PREFIX}.S_ADDRESS_1", '444 Easy St.'
        r.a "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_PREFIX}.S_ADDRESS_2", 'Apt 2D'
        r.a "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_PREFIX}.S_CITY", 'Chicago'
        r.a "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_PREFIX}.S_STATE", state
        r.a "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_PREFIX}.S_ZIP", '65432'
        r.a "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_PREFIX}.S_ZIP4", '6789'
      end

      response_set.responses.reload
      response_set.responses.size.should == 8

      OperationalDataExtractor::ParticipantVerification.new(response_set).extract_data

      person  = Person.find(@person.id)
      participant = person.participant
      participant.participant_person_links.size.should == 2
      child = participant.children.first

      child.addresses.should_not be_empty
      child.primary_address.to_s.should be_blank
      child.addresses.first.to_s.should == "444 Easy St. Apt 2D Chicago, Illinois 65432-6789"
    end

    it "creates a telephone record and associates it with the child" do
      response_set, instrument = prepare_instrument(@person, @child_participant, survey)

      take_survey(survey, response_set) do |r|
        r.a "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_CHILD_PREFIX}.C_FNAME", 'Baby'
        r.a "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_CHILD_PREFIX}.C_LNAME", 'James'
        r.a "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_PREFIX}.PA_PHONE", '312-555-1212'
      end

      response_set.responses.reload
      response_set.responses.size.should == 3

      OperationalDataExtractor::ParticipantVerification.new(response_set).extract_data

      child = Person.find(@child_participant.person.id)
      child.telephones.should_not be_empty
      child.primary_home_phone.to_s.should == '3125551212'
    end

    it "creates a 2ndary telephone record and associates it with the child" do
      response_set, instrument = prepare_instrument(@person, @child_participant, survey)

      take_survey(survey, response_set) do |r|
        r.a "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_CHILD_PREFIX}.C_FNAME", 'Baby'
        r.a "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_CHILD_PREFIX}.C_LNAME", 'James'
        r.a "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_PREFIX}.SA_PHONE", '312-555-4444'
      end

      response_set.responses.reload
      response_set.responses.size.should == 3

      OperationalDataExtractor::ParticipantVerification.new(response_set).extract_data

      child = Person.find(@child_participant.person.id)
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
    end

    it "extracts person operational data from the survey responses" do
      response_set, instrument = prepare_instrument(@person, @participant, survey)
      response_set.save!

      take_survey(survey, response_set) do |r|
        r.a "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_PREFIX}.R_FNAME", 'Jo'
        r.a "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_PREFIX}.R_MNAME", 'Anna'
        r.a "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_PREFIX}.R_LNAME", 'Stafford'
        r.a "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_PREFIX}.MAIDEN_NAME", 'Hitler'
        r.a "#{OperationalDataExtractor::ParticipantVerification::INTERVIEW_PREFIX}.PERSON_DOB", '1981-01-01'
      end

      response_set.responses.reload
      response_set.responses.size.should == 5

      OperationalDataExtractor::ParticipantVerification.new(response_set).extract_data

      person = Person.find(@person.id)
      person.first_name.should == "Jo"
      person.middle_name.should == "Anna"
      person.last_name.should == "Stafford"
      person.maiden_name.should == "Hitler"
      person.person_dob.should == "1981-01-01"
    end
  end

  context "setting instrument administration mode" do

    let(:person) { Factory(:person) }

    before(:each) do
      @participant = Factory(:participant)
      @participant.person = person
      @participant.save!

      @response_set, @instrument = prepare_instrument(person, @participant, survey, Instrument.cati)
    end

    it "sets the mode to CAPI" do
      take_survey(survey, @response_set) do |r|
        r.a "prepopulated_mode_of_contact", :reference_identifier => 'capi'
      end
      OperationalDataExtractor::ParticipantVerification.new(@response_set).extract_data
      Instrument.find(@instrument.id).instrument_mode_code.should == Instrument.capi
    end

    it "sets the mode to CATI" do
      take_survey(survey, @response_set) do |r|
        r.a "prepopulated_mode_of_contact", :reference_identifier => 'cati'
      end
      OperationalDataExtractor::ParticipantVerification.new(@response_set).extract_data
      Instrument.find(@instrument.id).instrument_mode_code.should == Instrument.cati
    end

    it "sets the mode to PAPI" do
      take_survey(survey, @response_set) do |r|
        r.a "prepopulated_mode_of_contact", :reference_identifier => 'papi'
      end
      OperationalDataExtractor::ParticipantVerification.new(@response_set).extract_data
      Instrument.find(@instrument.id).instrument_mode_code.should == Instrument.papi
    end
  end
end
