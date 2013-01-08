# -*- coding: utf-8 -*-


require 'spec_helper'

describe OperationalDataExtractor::PregnancyVisit do
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
    response_set, instrument = prepare_instrument(person, participant, survey)
    response_set.save!

    take_survey(survey, response_set) do |a|
      a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.R_FNAME", 'Jo'
      a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.R_LNAME", 'Stafford'
      a.date "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.PERSON_DOB", '01/01/1981'
      a.choice "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.AGE_ELIG", age_eligible
    end

    response_set.responses.reload
    response_set.responses.size.should == 4

    OperationalDataExtractor::PregnancyVisit.new(response_set).extract_data

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
      @response_set, @instrument = prepare_instrument(@person, @participant, @survey)
      @response_set.save!
      @participant.participant_person_links.size.should == 1
    end

    it "creates a new person (for the Child's Father) record and associates it with the particpant" do
      state = NcsCode.for_list_name_and_local_code("STATE_CL1", 14)

      survey = create_pregnancy_visit_1_saq_survey_with_father_operational_data
      survey_section = survey.sections.first
      response_set, instrument = prepare_instrument(@person, @participant, @survey)
      response_set.save!

      take_survey(survey, response_set) do |a|
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_SAQ_PREFIX}.FATHER_NAME", 'Lonnie Johnson'
        a.int "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_SAQ_PREFIX}.FATHER_AGE", 23
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_SAQ_PREFIX}.F_ADDR_1", '123 Easy St.'
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_SAQ_PREFIX}.F_ADDR_2", ''
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_SAQ_PREFIX}.F_UNIT", ''
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_SAQ_PREFIX}.F_CITY", 'Chicago'
        a.choice "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_SAQ_PREFIX}.F_STATE", state
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_SAQ_PREFIX}.F_ZIPCODE", '65432'
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_SAQ_PREFIX}.F_ZIP4", '1234'
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_SAQ_PREFIX}.F_PHONE", '3125551212'
      end

      response_set.responses.reload
      response_set.responses.size.should == 10

      OperationalDataExtractor::PregnancyVisit.new(response_set).extract_data

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
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CONTACT_FNAME_1", 'Donna'
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CONTACT_LNAME_1", 'Noble'
        a.choice "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CONTACT_RELATE_1", @contact_friend
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_ADDR_1_1", '123 Easy St.'
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_ADDR_2_1", ''
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_UNIT_1", ''
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_CITY_1", 'Chicago'
        a.choice "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_STATE_1", state
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_ZIP_1", '65432'
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_ZIP4_1", '1234'
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CONTACT_PHONE_1", '3125551212'
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 11

      OperationalDataExtractor::PregnancyVisit.new(@response_set).extract_data

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
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CONTACT_FNAME_2", 'Carole'
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CONTACT_LNAME_2", 'King'
        a.choice "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CONTACT_RELATE_2", @contact_neighbor
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_ADDR_1_2", '123 Tapestry St.'
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_ADDR_2_2", ''
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_UNIT_2", ''
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_CITY_2", 'Chicago'
        a.choice "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_STATE_2", state
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_ZIP_2", '65432'
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.C_ZIP4_2", '1234'
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CONTACT_PHONE_2", '3125551212'
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 11

      OperationalDataExtractor::PregnancyVisit.new(@response_set).extract_data

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
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CONTACT_FNAME_1", 'Ivy'
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CONTACT_LNAME_1", 'Anderson'
        a.choice "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CONTACT_RELATE_1", @contact_aunt_uncle
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 3

      OperationalDataExtractor::PregnancyVisit.new(@response_set).extract_data

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
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CONTACT_FNAME_1", 'Billie'
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CONTACT_LNAME_1", 'Holiday'
        a.choice "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CONTACT_RELATE_1", @contact_grandparent
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 3

      OperationalDataExtractor::PregnancyVisit.new(@response_set).extract_data

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
    participant = Factory(:participant)
    Factory(:telephone, :person => person)

    person.telephones.size.should == 1

    survey = create_pregnancy_visit_1_survey_with_telephone_operational_data
    response_set, instrument = prepare_instrument(person, participant, survey)
    response_set.save!

    take_survey(survey, response_set) do |a|
      a.yes "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CELL_PHONE_2"
      a.yes "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CELL_PHONE_4"
      a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CELL_PHONE", '3125557890'
    end

    response_set.responses.reload
    response_set.responses.size.should == 3

    OperationalDataExtractor::PregnancyVisit.new(response_set).extract_data

    person  = Person.find(person.id)
    person.telephones.size.should == 2
    person.telephones.first.phone_rank_code.should == 1

    telephone = person.telephones.last

    telephone.phone_type.should == cell
    telephone.phone_nbr.should == "3125557890"
    telephone.phone_rank_code.should == 1
    telephone.cell_permission.local_code.should == 1
    telephone.text_permission.local_code.should == 1
  end

  it "follows proper rank demotion rules if the types are identical" do

    cell = NcsCode.for_list_name_and_local_code("PHONE_TYPE_CL1", 3)

    person = Factory(:person)
    participant = Factory(:participant)
    Factory(:telephone, :person => person, :phone_type_code => 3)

    survey = create_pregnancy_visit_1_survey_with_telephone_operational_data
    response_set, instrument = prepare_instrument(person, participant, survey)

    take_survey(survey, response_set) do |a|
      a.yes "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CELL_PHONE_2"
      a.yes "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CELL_PHONE_4"
      a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.CELL_PHONE", '3125557890'
    end

    response_set.save!
    response_set.responses.count.should == 3

    OperationalDataExtractor::PregnancyVisit.new(response_set).extract_data

    person  = Person.find(person.id)
    person.telephones.count.should == 2
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

    participant = Factory(:participant)
    survey = create_pregnancy_visit_1_survey_with_email_operational_data
    survey_section = survey.sections.first
    response_set, instrument = prepare_instrument(person, participant, survey)
    response_set.save!
    response_set.responses.size.should == 0

    take_survey(survey, response_set) do |a|
      a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.EMAIL", 'email@dev.null'
    end

    response_set.responses.reload
    response_set.responses.size.should == 1

    OperationalDataExtractor::PregnancyVisit.new(response_set).extract_data

    person = Person.find(person.id)
    person.emails.size.should == 1
    person.emails.first.email.should == "email@dev.null"
    person.emails.first.email_rank_code.should == 1
  end

  it "extracts birth address operational data from the survey responses" do

    state = NcsCode.for_list_name_and_local_code("STATE_CL1", 14)

    person = Factory(:person)
    person.addresses.size.should == 0

    participant = Factory(:participant)
    survey = create_pregnancy_visit_survey_with_birth_address_operational_data
    response_set, instrument = prepare_instrument(person, participant, survey)
    response_set.save!

    take_survey(survey, response_set) do |a|
      a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.B_ADDR_1", '123 Hospital Way'
      a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.B_ADDR_2", ''
      a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.B_UNIT", ''
      a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.B_CITY", 'Chicago'
      a.choice "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.B_STATE", state
      a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_INTERVIEW_PREFIX}.B_ZIPCODE", '65432'
    end

    response_set.responses.reload
    response_set.responses.size.should == 6

    OperationalDataExtractor::PregnancyVisit.new(response_set).extract_data

    person  = Person.find(person.id)
    person.addresses.size.should == 1
    address = person.addresses.first
    address.to_s.should == "123 Hospital Way Chicago, ILLINOIS 65432"

  end

  context "determining the due date of a pregnant woman" do

    let(:ppg1) { NcsCode.for_list_name_and_local_code("PPG_STATUS_CL2", 1) }
    let(:neg_1) { stub(:local_code => 'neg_1') }
    let(:neg_2) { stub(:local_code => 'neg_2') }
    let(:tri1) { stub(:local_code => '1') }
    let(:tri2) { stub(:local_code => '2') }
    let(:tri3) { stub(:local_code => '3') }

    before(:each) do
      @person = Factory(:person)
      @participant = Factory(:participant)
      @participant.person = @person
      @participant.save!
      Factory(:ppg_detail, :participant => @participant)
    end

    context "for PBS PV1" do
      before(:each) do
        @survey = create_pbs_pregnancy_visit_1_with_due_date
        @response_set, @instrument = prepare_instrument(@person, @participant, @survey)
        @response_set.save!
      end

      it "sets the due date to the date provided by the participant" do
        due_date = Date.parse("2012-02-29")

        take_survey(@survey, @response_set) do |a|
          a.choice "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.PREGNANT", ppg1
          a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.DUE_DATE_MM", due_date.month
          a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.DUE_DATE_DD", due_date.day
          a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.DUE_DATE_YY", due_date.year
        end

        @response_set.responses.reload
        @response_set.responses.size.should == 4

        OperationalDataExtractor::PregnancyVisit.new(@response_set).extract_data

        person  = Person.find(@person.id)
        participant = person.participant
        participant.due_date.should == due_date
      end

      # # CALCULATE DUE DATE FROM THE FIRST DATE OF LAST MENSTRUAL PERIOD AND SET ORIG_DUE_DATE = DATE_PERIOD + 280 DAYS
      it "calculates the due date based on the date of the last menstrual period" do
        last_period = 20.weeks.ago.to_date
        take_survey(@survey, @response_set) do |a|
          a.choice "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.PREGNANT", ppg1
          a.choice "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.DUE_DATE_MM", neg_2
          a.choice "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.DUE_DATE_DD", neg_2
          a.choice "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.DUE_DATE_YY", neg_2

          a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.DATE_PERIOD", last_period.to_s
        end

        @response_set.responses.reload
        @response_set.responses.size.should == 5

        OperationalDataExtractor::PregnancyVisit.new(@response_set).extract_data

        person  = Person.find(@person.id)
        participant = person.participant
        participant.due_date.should == last_period + 280.days
      end

      it "does not set the due date if the date of the last menstrual period is not valid date" do
        last_period = "2012-92-92"
        take_survey(@survey, @response_set) do |a|
          a.choice "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.PREGNANT", ppg1
          a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.DATE_PERIOD", last_period
        end

        @response_set.responses.reload
        @response_set.responses.size.should == 2

        OperationalDataExtractor::PregnancyVisit.new(@response_set).extract_data

        person  = Person.find(@person.id)
        participant = person.participant
        participant.due_date.should be_nil
      end
    end

    context "for PBS PV2" do
      before(:each) do
        @survey = create_pbs_pregnancy_visit_2_with_due_date
        @response_set, @instrument = prepare_instrument(@person, @participant, @survey)
        @response_set.save!
      end

      it "sets the due date to the date provided by the participant" do
        due_date = "2012-02-29"
        take_survey(@survey, @response_set) do |a|
          a.choice "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.PREGNANT", ppg1
          a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.DUE_DATE", due_date
        end

        @response_set.responses.reload
        @response_set.responses.size.should == 2

        OperationalDataExtractor::PregnancyVisit.new(@response_set).extract_data

        person  = Person.find(@person.id)
        participant = person.participant
        participant.due_date.should == Date.parse("2012-02-29")
      end

      it "does not set the due date if date provided by the participant is not valid date" do
        due_date = "2012-92-92"
        take_survey(@survey, @response_set) do |a|
          a.choice "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.PREGNANT", ppg1
          a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.DUE_DATE", due_date
        end

        @response_set.responses.reload
        @response_set.responses.size.should == 2

        OperationalDataExtractor::PregnancyVisit.new(@response_set).extract_data

        person  = Person.find(@person.id)
        participant = person.participant
        participant.due_date.should be_nil
      end
    end
  end

  context "extracts address operational data from the survey responses" do

    before(:each) do
      @state = NcsCode.for_list_name_and_local_code("STATE_CL1", 14)
      @person = Factory(:person)
      @person.addresses.size.should == 0
      @participant = Factory(:participant)
    end

    it "for birth address for PBS PV1" do
      survey = create_pbs_pregnancy_visit_1_with_birth_address_operational_data
      response_set, instrument = prepare_instrument(@person, @participant, survey)
      response_set.save!

      take_survey(survey, response_set) do |a|
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.B_ADDRESS_1", '123 Hospital Way'
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.B_ADDRESS_2", ''
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.B_CITY", 'Chicago'
        a.choice "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.B_STATE", @state
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.B_ZIPCODE", '65432'
      end

      response_set.responses.reload
      response_set.responses.size.should == 5

      OperationalDataExtractor::PregnancyVisit.new(response_set).extract_data

      person  = Person.find(@person.id)
      person.addresses.size.should == 1
      address = person.addresses.first
      address.to_s.should == "123 Hospital Way Chicago, ILLINOIS 65432"
    end

    it "for work address for PBS PV1" do
      survey = create_pbs_pregnancy_visit_1_with_work_address_operational_data
      response_set, instrument = prepare_instrument(@person, @participant, survey)
      response_set.save!

      take_survey(survey, response_set) do |a|
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.WORK_ADDRESS_1", '123 Work Way'
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.WORK_ADDRESS_2", ''
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.WORK_UNIT", '3333'
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.WORK_CITY", 'Chicago'
        a.choice "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.WORK_STATE", @state
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.WORK_ZIPCODE", '65432'
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.WORK_ZIP4", '1234'
      end

      response_set.responses.reload
      response_set.responses.size.should == 7

      OperationalDataExtractor::PregnancyVisit.new(response_set).extract_data

      person  = Person.find(@person.id)
      person.addresses.size.should == 1
      address = person.addresses.first
      address.address_type.should == Address.work_address_type
      address.to_s.should == "123 Work Way 3333 Chicago, ILLINOIS 65432-1234"
    end

    it "for birth address for PBS PV2" do
      survey = create_pbs_pregnancy_visit_2_with_birth_address_operational_data
      response_set, instrument = prepare_instrument(@person, @participant, survey)
      response_set.save!

      take_survey(survey, response_set) do |a|
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.B_ADDRESS_1", '123 Hospital Way'
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.B_ADDRESS_2", ''
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.B_CITY", 'Chicago'
        a.choice "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.B_STATE", @state
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.B_ZIPCODE", '65432'
      end

      response_set.responses.reload
      response_set.responses.size.should == 5

      OperationalDataExtractor::PregnancyVisit.new(response_set).extract_data

      person  = Person.find(@person.id)
      person.addresses.size.should == 1
      address = person.addresses.first
      address.to_s.should == "123 Hospital Way Chicago, ILLINOIS 65432"
    end

    it "for work address for PBS PV2" do
      survey = create_pbs_pregnancy_visit_2_with_work_address_operational_data
      response_set, instrument = prepare_instrument(@person, @participant, survey)
      response_set.save!

      take_survey(survey, response_set) do |a|
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.WORK_ADDRESS_1", '123 Work Way'
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.WORK_ADDRESS_2", ''
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.WORK_UNIT", '3333'
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.WORK_CITY", 'Chicago'
        a.choice "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.WORK_STATE", @state
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.WORK_ZIPCODE", '65432'
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.WORK_ZIP4", '1234'
      end

      response_set.responses.reload
      response_set.responses.size.should == 7

      OperationalDataExtractor::PregnancyVisit.new(response_set).extract_data

      person  = Person.find(@person.id)
      person.addresses.size.should == 1
      address = person.addresses.first
      address.address_type.should == Address.work_address_type
      address.to_s.should == "123 Work Way 3333 Chicago, ILLINOIS 65432-1234"
    end

    it "for confirm work address for PBS PV2" do
      survey = create_pbs_pregnancy_visit_2_with_confirm_work_address_operational_data
      response_set, instrument = prepare_instrument(@person, @participant, survey)
      response_set.save!

      take_survey(survey, response_set) do |a|
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.CWORK_ADDRESS_1", '123 Confirm Work Way'
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.CWORK_ADDRESS_2", ''
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.CWORK_UNIT", '3333'
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.CWORK_CITY", 'Chicago'
        a.choice "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.CWORK_STATE", @state
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.CWORK_ZIPCODE", '65432'
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_2_3_INTERVIEW_PREFIX}.CWORK_ZIP4", '1234'
      end

      response_set.responses.reload
      response_set.responses.size.should == 7

      ode = OperationalDataExtractor::PregnancyVisit.new(response_set)
      ode.extract_data

      person  = Person.find(@person.id)
      person.addresses.size.should == 1
      address = person.addresses.first
      address.address_type.should == Address.work_address_type
      address.address_rank.should == ode.duplicate_rank
      address.to_s.should == "123 Confirm Work Way 3333 Chicago, ILLINOIS 65432-1234"
    end
  end

  context "setting instrument administration mode" do

    let(:person) { Factory(:person) }
    let(:survey) { create_pregnancy_visit_survey_with_prepopulated_fields }

    before(:each) do
      @participant = Factory(:participant)
      @participant.person = person
      @participant.save!

      @response_set, @instrument = prepare_instrument(person, @participant, survey)
    end

    it "sets the mode to CAPI" do
      take_survey(survey, @response_set) do |a|
        a.choice "prepopulated_mode_of_contact", mock(NcsCode, :local_code => "capi")
      end
      OperationalDataExtractor::PregnancyVisit.new(@response_set).extract_data
      Instrument.find(@instrument.id).instrument_mode_code.should == Instrument.capi
    end

    it "sets the mode to CATI" do
      take_survey(survey, @response_set) do |a|
        a.choice "prepopulated_mode_of_contact", mock(NcsCode, :local_code => "cati")
      end
      OperationalDataExtractor::PregnancyVisit.new(@response_set).extract_data
      Instrument.find(@instrument.id).instrument_mode_code.should == Instrument.cati
    end

    it "defaults to CATI" do
      OperationalDataExtractor::PregnancyVisit.new(@response_set).extract_data
      Instrument.find(@instrument.id).instrument_mode_code.should == Instrument.cati
    end

    it "sets the mode to PAPI" do
      take_survey(survey, @response_set) do |a|
        a.choice "prepopulated_mode_of_contact", mock(NcsCode, :local_code => "papi")
      end
      OperationalDataExtractor::PregnancyVisit.new(@response_set).extract_data
      Instrument.find(@instrument.id).instrument_mode_code.should == Instrument.papi
    end

  end
end