# -*- coding: utf-8 -*-

require 'spec_helper'

describe PregnancyVisitOperationalDataExtractor do
  include SurveyCompletion

  # R_FNAME               Person.first_name
  # R_LNAME               Person.last_name
  # PERSON_DOB            Person.person_dob
  it "extracts person operational data from the survey responses" do

    age_eligible  = NcsCode.for_list_name_and_local_code("AGE_ELIGIBLE_CL2", 1)

    person = Factory(:person, :age => nil)
    participant = Factory(:participant)
    ppl = Factory(:participant_person_link, :participant => participant, :person => person)

    survey = create_pregnancy_visit_1_survey_with_person_operational_data
    response_set, instrument = prepare_instrument(person, survey)
    response_set.save!

    take_survey(survey, response_set) do |a|
      a.str "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.R_FNAME", 'Jo'
      a.str "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.R_LNAME", 'Stafford'
      a.date "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.PERSON_DOB", '01/01/1981'
      a.choice "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.AGE_ELIG", age_eligible
    end

    response_set.responses.reload
    response_set.responses.size.should == 4

    PregnancyVisitOperationalDataExtractor.extract_data(response_set)

    person = Person.find(person.id)
    person.first_name.should == "Jo"
    person.last_name.should == "Stafford"
    person.person_dob.should == "1981-01-01"
    expected_age = Date.today.year - 1981
    person.computed_age.should == expected_age
    person.age.should == expected_age

    person.participant.pid_age_eligibility.display_text.should == age_eligible.display_text
    person.participant.pid_age_eligibility.local_code.should == age_eligible.local_code
    person.participant.pid_age_eligibility.list_name.should == age_eligible.list_name
  end

  context "extracting contact information from the survey responses" do

    before(:each) do
      @person = Factory(:person)
      @participant = Factory(:participant)
      @ppl = Factory(:participant_person_link, :participant => @participant, :person => @person)
      Factory(:ppg_detail, :participant => @participant)

      # CONTACT_RELATIONSHIP_CL2
      @contact_aunt_uncle = NcsCode.for_list_name_and_local_code("CONTACT_RELATIONSHIP_CL2", 3)
      @contact_grandparent = NcsCode.for_list_name_and_local_code("CONTACT_RELATIONSHIP_CL2", 4)
      @contact_neighbor = NcsCode.for_list_name_and_local_code("CONTACT_RELATIONSHIP_CL2", 5)
      @contact_friend = NcsCode.for_list_name_and_local_code("CONTACT_RELATIONSHIP_CL2", 6)

      # PERSON_PARTCPNT_RELTNSHP_CL1
      @ppr_grandparent = NcsCode.for_list_name_and_local_code("PERSON_PARTCPNT_RELTNSHP_CL1", 10)
      @ppr_other_rel = NcsCode.for_list_name_and_local_code("PERSON_PARTCPNT_RELTNSHP_CL1", 11)
      @ppr_friend = NcsCode.for_list_name_and_local_code("PERSON_PARTCPNT_RELTNSHP_CL1", 12)
      @ppr_neighbor = NcsCode.for_list_name_and_local_code("PERSON_PARTCPNT_RELTNSHP_CL1", 13)

      @survey = create_pregnancy_visit_1_survey_with_contact_operational_data
      @response_set, @instrument = prepare_instrument(@person, @survey)
      @response_set.save!
      @participant.participant_person_links.size.should == 1
    end

    it "creates a new person (for the Child's Father) record and associates it with the particpant" do
      state = NcsCode.for_list_name_and_local_code("STATE_CL1", 14)

      survey = create_pregnancy_visit_1_saq_survey_with_father_operational_data
      survey_section = survey.sections.first
      response_set, instrument = prepare_instrument(@person, @survey)
      response_set.save!

      take_survey(survey, response_set) do |a|
        a.str "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_SAQ_PREFIX}.FATHER_NAME", 'Lonnie Johnson'
        a.int "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_SAQ_PREFIX}.FATHER_AGE", 23
        a.str "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_SAQ_PREFIX}.F_ADDR_1", '123 Easy St.'
        a.str "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_SAQ_PREFIX}.F_ADDR_2", ''
        a.str "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_SAQ_PREFIX}.F_UNIT", ''
        a.str "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_SAQ_PREFIX}.F_CITY", 'Chicago'
        a.choice "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_SAQ_PREFIX}.F_STATE", state
        a.str "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_SAQ_PREFIX}.F_ZIPCODE", '65432'
        a.str "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_SAQ_PREFIX}.F_ZIP4", '1234'
        a.str "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_SAQ_PREFIX}.F_PHONE", '3125551212'
      end

      response_set.responses.reload
      response_set.responses.size.should == 10

      PregnancyVisitOperationalDataExtractor.extract_data(response_set)

      person  = Person.find(@person.id)
      participant = person.participant
      participant.participant_person_links.size.should == 2
      participant.partner.should_not be_nil
      father = participant.partner
      father.first_name.should == "Lonnie"
      father.last_name.should == "Johnson"
      father.telephones.first.should_not be_nil
      father.telephones.first.phone_nbr.should == "3125551212"
      father.telephones.first.phone_rank_code.should == 1

      father.addresses.first.should_not be_nil
      father.addresses.first.to_s.should == "123 Easy St. Chicago, ILLINOIS 65432-1234"
      father.addresses.first.address_rank_code.should == 1
    end

    it "creates a new person record and associates it with the particpant" do
      state = NcsCode.for_list_name_and_local_code("STATE_CL1", 14)

      take_survey(@survey, @response_set) do |a|
        a.str "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CONTACT_FNAME_1", 'Donna'
        a.str "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CONTACT_LNAME_1", 'Noble'
        a.choice "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CONTACT_RELATE_1", @contact_friend
        a.str "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_ADDR_1_1", '123 Easy St.'
        a.str "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_ADDR_2_1", ''
        a.str "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_UNIT_1", ''
        a.str "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_CITY_1", 'Chicago'
        a.choice "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_STATE_1", state
        a.str "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_ZIP_1", '65432'
        a.str "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_ZIP4_1", '1234'
        a.str "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CONTACT_PHONE_1", '3125551212'
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 11

      PregnancyVisitOperationalDataExtractor.extract_data(@response_set)

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
      friend.addresses.first.to_s.should == "123 Easy St. Chicago, ILLINOIS 65432-1234"
    end

    it "creates another new person record and associates it with the particpant" do
      state = NcsCode.for_list_name_and_local_code("STATE_CL1", 14)

      take_survey(@survey, @response_set) do |a|
        a.str "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CONTACT_FNAME_2", 'Carole'
        a.str "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CONTACT_LNAME_2", 'King'
        a.choice "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CONTACT_RELATE_2", @contact_neighbor
        a.str "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_ADDR_1_2", '123 Tapestry St.'
        a.str "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_ADDR_2_2", ''
        a.str "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_UNIT_2", ''
        a.str "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_CITY_2", 'Chicago'
        a.choice "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_STATE_2", state
        a.str "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_ZIP_2", '65432'
        a.str "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_ZIP4_2", '1234'
        a.str "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CONTACT_PHONE_2", '3125551212'
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 11

      PregnancyVisitOperationalDataExtractor.extract_data(@response_set)

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
      neighbor.addresses.first.to_s.should == "123 Tapestry St. Chicago, ILLINOIS 65432-1234"
    end

    it "creates an other relative person record and associates it with the particpant" do
      state = NcsCode.for_list_name_and_local_code("STATE_CL1", 14)

      take_survey(@survey, @response_set) do |a|
        a.str "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CONTACT_FNAME_1", 'Ivy'
        a.str "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CONTACT_LNAME_1", 'Anderson'
        a.choice "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CONTACT_RELATE_1", @contact_aunt_uncle
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 3

      PregnancyVisitOperationalDataExtractor.extract_data(@response_set)

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

      take_survey(@survey, @response_set) do |a|
        a.str "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CONTACT_FNAME_1", 'Billie'
        a.str "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CONTACT_LNAME_1", 'Holiday'
        a.choice "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CONTACT_RELATE_1", @contact_grandparent
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 3

      PregnancyVisitOperationalDataExtractor.extract_data(@response_set)

      person  = Person.find(@person.id)
      participant = person.participant
      participant.participant_person_links.size.should == 2
      participant.grandparents.size.should == 1
      mimi = participant.grandparents.first
      mimi.first_name.should == "Billie"
      mimi.last_name.should == "Holiday"
    end

  end

  it "extracts cell phone operational data from the survey responses" do

    cell = NcsCode.for_list_name_and_local_code("PHONE_TYPE_CL1", 3)

    person = Factory(:person)

    Factory(:telephone, :person => person)

    person.telephones.size.should == 1

    survey = create_pregnancy_visit_1_survey_with_telephone_operational_data
    response_set, instrument = prepare_instrument(person, survey)
    response_set.save!

    take_survey(survey, response_set) do |a|
      a.yes "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CELL_PHONE_2"
      a.yes "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CELL_PHONE_4"
      a.str "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CELL_PHONE", '3125557890'
    end

    response_set.responses.reload
    response_set.responses.size.should == 3

    PregnancyVisitOperationalDataExtractor.extract_data(response_set)

    person  = Person.find(person.id)
    person.telephones.size.should == 2
    person.telephones.first.phone_rank_code.should == 2

    telephone = person.telephones.last

    telephone.phone_type.should == cell
    telephone.phone_nbr.should == "3125557890"
    telephone.phone_rank_code.should == 1
    telephone.cell_permission.local_code.should == 1
    telephone.text_permission.local_code.should == 1
  end

  it "extracts email operational data from the survey responses" do
    person = Factory(:person)
    person.telephones.size.should == 0

    survey = create_pregnancy_visit_1_survey_with_email_operational_data
    survey_section = survey.sections.first
    response_set, instrument = prepare_instrument(person, survey)
    response_set.save!
    response_set.responses.size.should == 0

    take_survey(survey, response_set) do |a|
      a.str "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.EMAIL", 'email@dev.null'
    end

    response_set.responses.reload
    response_set.responses.size.should == 1

    PregnancyVisitOperationalDataExtractor.extract_data(response_set)

    person = Person.find(person.id)
    person.emails.size.should == 1
    person.emails.first.email.should == "email@dev.null"
    person.emails.first.email_rank_code.should == 1
  end

  it "extracts birth address operational data from the survey responses" do

    state = NcsCode.for_list_name_and_local_code("STATE_CL1", 14)

    person = Factory(:person)
    person.addresses.size.should == 0

    survey = create_pregnancy_visit_survey_with_birth_address_operational_data
    response_set, instrument = prepare_instrument(person, survey)
    response_set.save!

    take_survey(survey, response_set) do |a|
      a.str "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.B_ADDR_1", '123 Hospital Way'
      a.str "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.B_ADDR_2", ''
      a.str "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.B_UNIT", ''
      a.str "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.B_CITY", 'Chicago'
      a.choice "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.B_STATE", state
      a.str "#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.B_ZIPCODE", '65432'
    end

    response_set.responses.reload
    response_set.responses.size.should == 6

    PregnancyVisitOperationalDataExtractor.extract_data(response_set)

    person  = Person.find(person.id)
    person.addresses.size.should == 1
    address = person.addresses.first
    address.to_s.should == "123 Hospital Way Chicago, ILLINOIS 65432"

  end

end
