# -*- coding: utf-8 -*-

require 'spec_helper'

describe OperationalDataExtractor::PrePregnancy do
  include SurveyCompletion

  it "extracts person operational data from the survey responses" do

    married = NcsCode.for_list_name_and_local_code("MARITAL_STATUS_CL1", 1)

    age_eligible  = NcsCode.for_list_name_and_local_code("AGE_ELIGIBLE_CL2", 3)
    age_eligible2 = NcsCode.for_list_name_and_local_code("AGE_ELIGIBLE_CL4", 3)

    person = Factory(:person, :age => nil)
    participant = Factory(:participant)
    participant.person = person
    participant.save!

    survey = create_pre_pregnancy_survey_with_person_operational_data
    response_set, instrument = prepare_instrument(person, participant, survey)
    response_set.save!
    response_set.responses.size.should == 0

    take_survey(survey, response_set) do |r|
      r.a "#{OperationalDataExtractor::PrePregnancy::INTERVIEW_PREFIX}.R_FNAME", 'Jo'
      r.a "#{OperationalDataExtractor::PrePregnancy::INTERVIEW_PREFIX}.R_LNAME", 'Stafford'
      r.a "#{OperationalDataExtractor::PrePregnancy::INTERVIEW_PREFIX}.PERSON_DOB", '1981-01-01'
      r.a "#{OperationalDataExtractor::PrePregnancy::INTERVIEW_PREFIX}.MARISTAT", married
    end

    response_set.responses.reload
    response_set.responses.size.should == 4

    OperationalDataExtractor::PrePregnancy.new(response_set).extract_data

    person = Person.find(person.id)
    person.first_name.should == "Jo"
    person.last_name.should == "Stafford"
    person.person_dob.should == "1981-01-01"
    expected_age = Date.today.year - 1981
    person.computed_age.should == expected_age
    person.age.should == expected_age

    person.marital_status.should == married
  end

  it "extracts cell phone operational data from the survey responses" do

    cell = NcsCode.for_list_name_and_local_code("PHONE_TYPE_CL1", 3)

    person = Factory(:person)
    participant = Factory(:participant)
    participant.person = person
    participant.save!
    person.telephones.size.should == 0

    survey = create_pre_pregnancy_survey_with_telephone_operational_data
    response_set, instrument = prepare_instrument(person, participant, survey)
    response_set.save!
    response_set.responses.size.should == 0

    take_survey(survey, response_set) do |r|
      r.yes "#{OperationalDataExtractor::PrePregnancy::INTERVIEW_PREFIX}.CELL_PHONE_2"
      r.yes "#{OperationalDataExtractor::PrePregnancy::INTERVIEW_PREFIX}.CELL_PHONE_4"
      r.a "#{OperationalDataExtractor::PrePregnancy::INTERVIEW_PREFIX}.CELL_PHONE", '3125557890'
    end

    response_set.responses.reload
    response_set.responses.size.should == 3

    OperationalDataExtractor::PrePregnancy.new(response_set).extract_data

    person  = Person.find(person.id)
    person.telephones.size.should == 1
    telephone = person.telephones.first

    telephone.phone_type.should == cell
    telephone.phone_nbr.should == "3125557890"
    telephone.phone_rank_code.should == 1

  end

  it "extracts email operational data from the survey responses" do
    person = Factory(:person)
    participant = Factory(:participant)
    participant.person = person
    participant.save!
    person.telephones.size.should == 0

    email = Factory(:email, :email => "asdf@asdf.asdf", :email_type_code => 1, :person => person)

    survey = create_pre_pregnancy_survey_with_email_operational_data
    response_set, instrument = prepare_instrument(person, participant, survey)
    response_set.save!
    response_set.responses.size.should == 0

    take_survey(survey, response_set) do |r|
      r.a "#{OperationalDataExtractor::PrePregnancy::INTERVIEW_PREFIX}.EMAIL", 'email@dev.null'
    end

    response_set.responses.reload
    response_set.responses.size.should == 1

    OperationalDataExtractor::PrePregnancy.new(response_set).extract_data

    person = Person.find(person.id)

    extracted_emails = person.emails.all
    extracted_emails.size == 2

    extracted_email_addresses = []
    extracted_emails.each { |email| extracted_email_addresses << email.email }

    extracted_email_addresses.should include("asdf@asdf.asdf")
    extracted_email_addresses.should include("email@dev.null")

    existing_email = extracted_emails.detect  { |e| e.email == "asdf@asdf.asdf" }
    extracted_email = extracted_emails.detect { |e| e.email == "email@dev.null" }

    # when an email of the same type of an existing primary email address, the existing address is demoted to secondary rank (2) and
    # newly extracted email has the primary rank (1)

    existing_email.email_rank_code.should == 2
    extracted_email.email_rank_code.should == 1
  end

  context "extracting contact information from the survey responses" do

    before(:each) do
      @contact_aunt_uncle = NcsCode.for_list_name_and_local_code("CONTACT_RELATIONSHIP_CL2", 3)
      @contact_grandparent = NcsCode.for_list_name_and_local_code("CONTACT_RELATIONSHIP_CL2", 4)
      @contact_neighbor = NcsCode.for_list_name_and_local_code("CONTACT_RELATIONSHIP_CL2", 5)
      @contact_friend = NcsCode.for_list_name_and_local_code("CONTACT_RELATIONSHIP_CL2", 6)

      @person = Factory(:person)
      @participant = Factory(:participant)
      @participant.person = @person
      @participant.save!
      Factory(:ppg_detail, :participant => @participant)

      # CONTACT_RELATIONSHIP_CL2

      # PERSON_PARTCPNT_RELTNSHP_CL1
      @ppr_grandparent = NcsCode.for_list_name_and_local_code("PERSON_PARTCPNT_RELTNSHP_CL1", 10)
      @ppr_other_rel = NcsCode.for_list_name_and_local_code("PERSON_PARTCPNT_RELTNSHP_CL1", 11)
      @ppr_friend = NcsCode.for_list_name_and_local_code("PERSON_PARTCPNT_RELTNSHP_CL1", 12)
      @ppr_neighbor = NcsCode.for_list_name_and_local_code("PERSON_PARTCPNT_RELTNSHP_CL1", 13)

      @survey = create_pre_pregnancy_survey_with_contact_operational_data
      @response_set, @instrument = prepare_instrument(@person, @participant, @survey)
      @response_set.save!
      @response_set.responses.size.should == 0
      @participant.participant_person_links.size.should == 1
    end

    it "creates a new person record and associates it with the particpant" do
      state = NcsCode.for_list_name_and_local_code("STATE_CL1", 14)

      take_survey(@survey, @response_set) do |r|
        r.a "#{OperationalDataExtractor::PrePregnancy::INTERVIEW_PREFIX}.CONTACT_FNAME_1", 'Donna'
        r.a "#{OperationalDataExtractor::PrePregnancy::INTERVIEW_PREFIX}.CONTACT_LNAME_1", 'Noble'
        r.a "#{OperationalDataExtractor::PrePregnancy::INTERVIEW_PREFIX}.CONTACT_RELATE_1", @contact_friend
        r.a "#{OperationalDataExtractor::PrePregnancy::INTERVIEW_PREFIX}.C_ADDR_1_1", '123 Easy St.'
        r.a "#{OperationalDataExtractor::PrePregnancy::INTERVIEW_PREFIX}.C_ADDR_2_1", ''
        r.a "#{OperationalDataExtractor::PrePregnancy::INTERVIEW_PREFIX}.C_UNIT_1", ''
        r.a "#{OperationalDataExtractor::PrePregnancy::INTERVIEW_PREFIX}.C_CITY_1", 'Chicago'
        r.a "#{OperationalDataExtractor::PrePregnancy::INTERVIEW_PREFIX}.C_STATE_1", state
        r.a "#{OperationalDataExtractor::PrePregnancy::INTERVIEW_PREFIX}.C_ZIP_1", '65432'
        r.a "#{OperationalDataExtractor::PrePregnancy::INTERVIEW_PREFIX}.C_ZIP4_1", '1234'
        r.a "#{OperationalDataExtractor::PrePregnancy::INTERVIEW_PREFIX}.CONTACT_PHONE_1", '3125551212'
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 11

      OperationalDataExtractor::PrePregnancy.new(@response_set).extract_data

      person  = Person.find(@person.id)
      participant = person.participant
      participant.participant_person_links.size.should == 2
      participant.friends.size.should == 1
      friend = participant.friends.first
      friend.first_name.should == "Donna"
      friend.last_name.should == "Noble"
      friend.telephones.first.should_not be_nil
      friend.telephones.first.phone_nbr.should == "3125551212"

      friend.addresses.first.should_not be_nil
      friend.addresses.first.to_s.should == "123 Easy St. Chicago, Illinois 65432-1234"
      friend.addresses.first.address_rank_code.should == 1
    end

    it "creates another new person record and associates it with the particpant" do
      state = NcsCode.for_list_name_and_local_code("STATE_CL1", 14)

      take_survey(@survey, @response_set) do |r|
        r.a "#{OperationalDataExtractor::PrePregnancy::INTERVIEW_PREFIX}.CONTACT_FNAME_2", 'Carole'
        r.a "#{OperationalDataExtractor::PrePregnancy::INTERVIEW_PREFIX}.CONTACT_LNAME_2", 'King'
        r.a "#{OperationalDataExtractor::PrePregnancy::INTERVIEW_PREFIX}.CONTACT_RELATE_2", @contact_neighbor
        r.a "#{OperationalDataExtractor::PrePregnancy::INTERVIEW_PREFIX}.C_ADDR_1_2", '123 Tapestry St.'
        r.a "#{OperationalDataExtractor::PrePregnancy::INTERVIEW_PREFIX}.C_ADDR_2_2", ''
        r.a "#{OperationalDataExtractor::PrePregnancy::INTERVIEW_PREFIX}.C_UNIT_2", ''
        r.a "#{OperationalDataExtractor::PrePregnancy::INTERVIEW_PREFIX}.C_CITY_2", 'Chicago'
        r.a "#{OperationalDataExtractor::PrePregnancy::INTERVIEW_PREFIX}.C_STATE_2", state
        r.a "#{OperationalDataExtractor::PrePregnancy::INTERVIEW_PREFIX}.C_ZIP_2", '65432'
        r.a "#{OperationalDataExtractor::PrePregnancy::INTERVIEW_PREFIX}.C_ZIP4_2", '1234'
        r.a "#{OperationalDataExtractor::PrePregnancy::INTERVIEW_PREFIX}.CONTACT_PHONE_2", '3125551212'
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 11

      OperationalDataExtractor::PrePregnancy.new(@response_set).extract_data

      person  = Person.find(@person.id)
      participant = person.participant
      participant.participant_person_links.size.should == 2
      participant.neighbors.size.should == 1
      neighbor = participant.neighbors.first
      neighbor.first_name.should == "Carole"
      neighbor.last_name.should == "King"
      neighbor.telephones.first.should_not be_nil
      neighbor.telephones.first.phone_nbr.should == "3125551212"

      neighbor.addresses.first.should_not be_nil
      neighbor.addresses.first.to_s.should == "123 Tapestry St. Chicago, Illinois 65432-1234"
    end

    it "creates an other relative person record and associates it with the particpant" do
      state = NcsCode.for_list_name_and_local_code("STATE_CL1", 14)

      take_survey(@survey, @response_set) do |r|
        r.a "#{OperationalDataExtractor::PrePregnancy::INTERVIEW_PREFIX}.CONTACT_FNAME_1", 'Ivy'
        r.a "#{OperationalDataExtractor::PrePregnancy::INTERVIEW_PREFIX}.CONTACT_LNAME_1", 'Anderson'
        r.a "#{OperationalDataExtractor::PrePregnancy::INTERVIEW_PREFIX}.CONTACT_RELATE_1", @contact_aunt_uncle
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 3

      OperationalDataExtractor::PrePregnancy.new(@response_set).extract_data

      person  = Person.find(@person.id)
      participant = person.participant
      participant.participant_person_links.size.should == 2
      participant.other_relatives.size.should == 1
      aunt = participant.other_relatives.first
      aunt.first_name.should == "Ivy"
      aunt.last_name.should == "Anderson"
    end

    it "creates a grandparent person record and associates it with the particpant" do
      state = NcsCode.for_list_name_and_local_code("STATE_CL1", 14)

      take_survey(@survey, @response_set) do |r|
        r.a "#{OperationalDataExtractor::PrePregnancy::INTERVIEW_PREFIX}.CONTACT_FNAME_1", 'Billie'
        r.a "#{OperationalDataExtractor::PrePregnancy::INTERVIEW_PREFIX}.CONTACT_LNAME_1", 'Holiday'
        r.a "#{OperationalDataExtractor::PrePregnancy::INTERVIEW_PREFIX}.CONTACT_RELATE_1", @contact_grandparent
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 3

      OperationalDataExtractor::PrePregnancy.new(@response_set).extract_data

      person  = Person.find(@person.id)
      participant = person.participant
      participant.participant_person_links.size.should == 2
      participant.grandparents.size.should == 1
      mimi = participant.grandparents.first
      mimi.first_name.should == "Billie"
      mimi.last_name.should == "Holiday"
    end

  end

end
