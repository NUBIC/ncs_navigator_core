# -*- coding: utf-8 -*-


require 'spec_helper'

describe OperationalDataExtractor::PbsEligibilityScreener do
  include SurveyCompletion

  context "extracting person operational data" do

    let(:age_range)             { NcsCode.for_list_name_and_local_code("AGE_RANGE_CL8", 2) }
    let(:age_range_refused)     { NcsCode.for_list_name_and_local_code("AGE_RANGE_CL8", -1) }
    let(:ethnic_group)          { NcsCode.for_list_name_and_local_code("ETHNICITY_CL1", 2) }
    let(:ethnic_group_refused)  { NcsCode.for_list_name_and_local_code("ETHNICITY_CL1", -1) }
    let(:language)              { NcsCode.for_list_name_and_local_code("LANGUAGE_CL10", 1) }
    let(:age_eligible)          { NcsCode.for_list_name_and_local_code("AGE_ELIGIBLE_CL2", 1) }
    let(:entered_age)           { 30 }

    before(:each) do
      @person = Factory(:person, :first_name => nil, :last_name => nil, :middle_name => nil, :person_dob => nil)
      @participant = Factory(:participant)
      @participant.person = @person
      @survey = create_pbs_eligibility_screener_survey_with_person_operational_data
    end

    it "extracts person operational data from the survey responses" do
      response_set, instrument = prepare_instrument(@person, @participant, @survey)
      response_set.save!

      take_survey(@survey, response_set) do |a|
        a.str "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.R_FNAME", 'Jo'
        a.str "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.R_MNAME", 'Anna'
        a.str "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.R_LNAME", 'Stafford'
        a.date "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.PERSON_DOB", '01/01/1981'
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.AGE_RANGE_PBS", age_range
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ETHNIC_ORIGIN", ethnic_group
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.PERSON_LANG_NEW", language
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.AGE_ELIG", age_eligible
      end

      response_set.responses.reload
      response_set.responses.size.should == 8

      OperationalDataExtractor::PbsEligibilityScreener.extract_data(response_set)

      person = Person.find(@person.id)
      person.first_name.should == "Jo"
      person.middle_name.should == "Anna"
      person.last_name.should == "Stafford"
      person.person_dob.should == "1981-01-01"

      expected_age = Date.today.year - 1981
      person.computed_age.should == expected_age

      person.age_range.local_code.should == -6 # unknown
      person.ethnic_group.should == ethnic_group
      person.language_new.to_s.should == language.to_s

      person.participant.pid_age_eligibility.display_text.should == age_eligible.display_text
      person.participant.pid_age_eligibility.local_code.should == age_eligible.local_code
    end

    it "does not set negative values for non coded person operational data" do
      response_set, instrument = prepare_instrument(@person, @participant, @survey)
      response_set.save!

      take_survey(@survey, response_set) do |a|
        a.refused "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.R_FNAME"
        a.refused "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.R_MNAME"
        a.refused "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.R_LNAME"
        a.dont_know "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.PERSON_DOB"
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.AGE_RANGE_PBS", age_range_refused
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ETHNIC_ORIGIN", ethnic_group_refused
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.PERSON_LANG_NEW", language
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.AGE_ELIG", age_eligible
      end

      response_set.responses.reload
      response_set.responses.size.should == 8

      OperationalDataExtractor::PbsEligibilityScreener.extract_data(response_set)

      person = Person.find(@person.id)
      person.first_name.should be_nil
      person.middle_name.should be_nil
      person.last_name.should be_nil
      person.person_dob.should be_nil

      person.age_range.local_code.should == -1
      person.ethnic_group.should == ethnic_group_refused
    end
  end

  describe "address" do

    it "extracts operational data from the survey responses" do
      state = NcsCode.for_list_name_and_local_code("STATE_CL1", 14)
      person = Factory(:person)
      participant = Factory(:participant)
      survey = create_pbs_eligibility_screener_survey_with_address_operational_data

      person.addresses.size.should == 0
      response_set, instrument = prepare_instrument(person, participant, survey)
      response_set.save!

      take_survey(survey, response_set) do |a|
        a.str "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ADDRESS_1", '123 Easy St.'
        a.str "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ADDRESS_2", ''
        a.str "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.UNIT", ''
        a.str "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.CITY", 'Chicago'
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.STATE", state
        a.str "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ZIP", '65432'
        a.str "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ZIP4", '1234'
      end

      response_set.responses.reload
      response_set.responses.size.should == 7

      OperationalDataExtractor::PbsEligibilityScreener.extract_data(response_set)

      person = Person.find(person.id)
      person.addresses.size.should == 1
      address = person.addresses.first
      address.to_s.should == "123 Easy St. Chicago, ILLINOIS 65432-1234"
      address.address_rank_code.should == 1
    end

    it "does not set negative values for non coded attributes" do
      state = NcsCode.for_list_name_and_local_code("STATE_CL1", 14)
      person = Factory(:person)
      participant = Factory(:participant)
      survey = create_pbs_eligibility_screener_survey_with_address_operational_data
      person.addresses.size.should == 0
      response_set, instrument = prepare_instrument(person, participant, survey)
      response_set.save!

      take_survey(survey, response_set) do |a|
        a.str "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ADDRESS_1", '123 Easy St.'
        a.refused "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ADDRESS_2"
        a.dont_know "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.UNIT"
        a.str "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.CITY", 'Chicago'
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.STATE", state
        a.refused "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ZIP"
        a.dont_know "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ZIP4"
      end

      response_set.responses.reload
      response_set.responses.size.should == 7

      OperationalDataExtractor::PbsEligibilityScreener.extract_data(response_set)

      person = Person.find(person.id)
      person.addresses.size.should == 1
      address = person.addresses.first
      address.to_s.should == "123 Easy St. Chicago, ILLINOIS"
      address.address_rank_code.should == 1
    end

    it "does not set invalid values" do
      state = NcsCode.for_list_name_and_local_code("STATE_CL1", 14)
      person = Factory(:person)
      participant = Factory(:participant)
      survey = create_pbs_eligibility_screener_survey_with_address_operational_data
      person.addresses.size.should == 0
      response_set, instrument = prepare_instrument(person, participant, survey)
      response_set.save!

      take_survey(survey, response_set) do |a|
        a.str "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ADDRESS_1", '123 Easy St.'
        a.refused "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ADDRESS_2"
        a.str "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.UNIT", "123456789987654321"
        a.str "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.CITY", 'Chicago'
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.STATE", state
        a.refused "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ZIP"
        a.dont_know "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ZIP4"
      end

      response_set.responses.reload
      response_set.responses.size.should == 7

      OperationalDataExtractor::PbsEligibilityScreener.extract_data(response_set)

      person = Person.find(person.id)
      person.addresses.size.should == 1
      address = person.addresses.first
      address.to_s.should == "123 Easy St. Chicago, ILLINOIS"
      address.address_rank_code.should == 1
    end

  end

  context "extracting telephone operational data from the survey responses" do

    let(:home) { NcsCode.for_list_name_and_local_code("PHONE_TYPE_CL1", 1) }
    let(:work) { NcsCode.for_list_name_and_local_code("PHONE_TYPE_CL1", 2) }
    let(:cell) { NcsCode.for_list_name_and_local_code("PHONE_TYPE_CL1", 3) }

    before(:each) do
      @person = Factory(:person)
      @person.telephones.size.should == 0

      @participant = Factory(:participant)
      @survey = create_pbs_eligibility_screener_survey_with_telephone_operational_data
    end

    it "extracts telephone operational data" do
      response_set, instrument = prepare_instrument(@person, @participant, @survey)
      response_set.save!

      take_survey(@survey, response_set) do |a|
        a.str "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.R_PHONE_1", '3125551234'
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.R_PHONE_TYPE1", home
        a.str "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.R_PHONE_TYPE1_OTH", ''
        a.str "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.R_PHONE_2", '3125554321'
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.R_PHONE_TYPE2", cell
        a.str "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.R_PHONE_TYPE2_OTH", ''
      end

      response_set.responses.reload
      response_set.responses.size.should == 6

      OperationalDataExtractor::PbsEligibilityScreener.extract_data(response_set)

      person  = Person.find(@person.id)
      person.telephones.size.should == 2
      person.telephones.each do |t|
        t.phone_type.should_not be_nil
        t.phone_nbr[0,6].should == "312555"
        t.phone_rank_code.should == 1
      end

    end
  end

  it "extracts email information from the survey responses" do

    person = Factory(:person)
    person.emails.size.should == 0

    participant = Factory(:participant)
    survey = create_pbs_eligibility_screener_survey_with_email_operational_data
    response_set, instrument = prepare_instrument(person, participant, survey)
    response_set.save!

    take_survey(survey, response_set) do |a|
      a.str "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.R_EMAIL", 'email@dev.null'
    end

    response_set.responses.reload
    response_set.responses.size.should == 1

    OperationalDataExtractor::PbsEligibilityScreener.extract_data(response_set)

    person  = Person.find(person.id)
    person.emails.size.should == 1
    person.emails.first.email.should == "email@dev.null"
    person.emails.first.email_rank_code.should == 1

  end

  it "sets the ppg detail ppg status to 1 if the person responds that they are pregnant" do

    person = Factory(:person)
    participant = Factory(:participant)
    ppl = Factory(:participant_person_link, :participant => participant, :person => person)

    ppg1 = NcsCode.for_list_name_and_local_code("PPG_STATUS_CL2", 1)

    p_type = NcsCode.for_list_name_and_local_code("PARTICIPANT_TYPE_CL1", 3)

    survey = create_pbs_eligibility_screener_survey_with_ppg_detail_operational_data
    response_set, instrument = prepare_instrument(person, participant, survey)
    response_set.save!

    take_survey(survey, response_set) do |a|
      a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.PREGNANT", ppg1
    end

    response_set.responses.reload
    response_set.responses.size.should == 1

    OperationalDataExtractor::PbsEligibilityScreener.extract_data(response_set)

    person  = Person.find(person.id)
    participant = person.participant
    participant.ppg_details.size.should == 1
    participant.ppg_details.first.ppg_first.local_code.should == 1
    participant.ppg_status.local_code.should == 1
    participant.p_type.should == p_type

  end

  it "sets the ppg detail ppg status to 2 if the person responds that they are trying to become pregnant" do

    person = Factory(:person)
    participant = Factory(:participant)
    ppl = Factory(:participant_person_link, :participant => participant, :person => person)

    ppg2 = NcsCode.for_list_name_and_local_code("PPG_STATUS_CL2", 2)

    p_type = NcsCode.for_list_name_and_local_code("PARTICIPANT_TYPE_CL1", 2)

    survey = create_pbs_eligibility_screener_survey_with_ppg_detail_operational_data
    response_set, instrument = prepare_instrument(person, participant, survey)
    response_set.save!

    take_survey(survey, response_set) do |a|
      a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.PREGNANT", ppg2
    end

    response_set.responses.reload
    response_set.responses.size.should == 1

    OperationalDataExtractor::PbsEligibilityScreener.extract_data(response_set)

    person  = Person.find(person.id)
    participant = person.participant
    participant.ppg_details.size.should == 1
    participant.ppg_details.first.ppg_first.local_code.should == 2
    participant.ppg_status.local_code.should == 2
    participant.due_date.should be_nil
    participant.p_type.should == p_type

  end

  it "sets the ppg detail ppg status to 5 if the person responds that they are unable to become pregnant" do

    person = Factory(:person)
    participant = Factory(:participant)
    ppl = Factory(:participant_person_link, :participant => participant, :person => person)

    ppg5 = NcsCode.for_list_name_and_local_code("PPG_STATUS_CL2", 5)

    survey = create_pbs_eligibility_screener_survey_with_ppg_detail_operational_data
    response_set, instrument = prepare_instrument(person, participant, survey)
    response_set.save!

    take_survey(survey, response_set) do |a|
      a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.PREGNANT", ppg5
    end

    response_set.responses.reload
    response_set.responses.size.should == 1

    OperationalDataExtractor::PbsEligibilityScreener.extract_data(response_set)

    person  = Person.find(person.id)
    participant = person.participant
    participant.ppg_details.size.should == 1
    participant.ppg_details.first.ppg_first.local_code.should == 5
    participant.ppg_status.local_code.should == 5
    participant.due_date.should be_nil
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

      @survey = create_pbs_eligibility_screener_survey_to_determine_due_date

      @response_set, @instrument = prepare_instrument(@person, @participant, @survey)
      @response_set.save!
    end

    it "sets the due date to the date provided by the participant" do
      due_date = Date.parse("2012-02-29")
      take_survey(@survey, @response_set) do |a|
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.PREGNANT", ppg1
        a.str "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_MM", due_date.month
        a.str "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_DD", due_date.day
        a.str "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_YY", due_date.year
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 4

      OperationalDataExtractor::PbsEligibilityScreener.extract_data(@response_set)

      person  = Person.find(@person.id)
      participant = person.participant
      participant.due_date.should == due_date

    end

    # # CALCULATE DUE DATE FROM THE FIRST DATE OF LAST MENSTRUAL PERIOD AND SET ORIG_DUE_DATE = DATE_PERIOD + 280 DAYS
    it "calculates the due date based on the date of the last menstrual period" do

      last_period = 20.weeks.ago

      take_survey(@survey, @response_set) do |a|
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.PREGNANT", ppg1
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_MM", neg_2
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_DD", neg_2
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_YY", neg_2

        a.str "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_MM", last_period.month
        a.str "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_DD", last_period.day
        a.str "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_YY", last_period.year
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 7

      OperationalDataExtractor::PbsEligibilityScreener.extract_data(@response_set)

      person  = Person.find(@person.id)
      participant = person.participant
      participant.due_date.should == (last_period + 280.days).to_date

    end

    # CALCULATE ORIG_DUE_DATE =TODAY’S DATE + 280 DAYS – WEEKS_PREG * 7
    it "calculates the due date based on the number of weeks pregnant" do

      weeks_pregnant = 8

      take_survey(@survey, @response_set) do |a|
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.PREGNANT", ppg1
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_MM", neg_2
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_DD", neg_2
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_YY", neg_2
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_MM", neg_1
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_DD", neg_1
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_YY", neg_1

        a.int "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.WEEKS_PREG", weeks_pregnant
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 8

      OperationalDataExtractor::PbsEligibilityScreener.extract_data(@response_set)

      person  = Person.find(@person.id)
      participant = person.participant
      participant.due_date.should == ((Date.today + 280.days) - (weeks_pregnant * 7)).to_date

    end

    # CALCULATE DUE DATE AS FROM NUMBER OF MONTHS PREGNANT WHERE ORIG_DUE_DATE =TODAY’S DATE + 280 DAYS – MONTH_PREG * 30 - 15
    it "calculates the due date based on the number of months pregnant" do
      months_pregnant = 4

      take_survey(@survey, @response_set) do |a|
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.PREGNANT", ppg1
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_MM", neg_2
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_DD", neg_2
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_YY", neg_2
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_MM", neg_1
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_DD", neg_1
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_YY", neg_1
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.WEEKS_PREG", neg_2
        a.int "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.MONTH_PREG", months_pregnant
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 9

      OperationalDataExtractor::PbsEligibilityScreener.extract_data(@response_set)

      person  = Person.find(@person.id)
      participant = person.participant
      participant.due_date.should == ((Date.today + 280.days) - ((months_pregnant * 30) - 15)).to_date

    end

    # 1ST TRIMESTER:      ORIG_DUE_DATE = TODAY’S DATE + (280 DAYS – 46 DAYS).
    # 2ND TRIMESTER:      ORIG_DUE_DATE = TODAY’S DATE + (280 DAYS – 140 DAYS).
    # 3RD TRIMESTER:      ORIG_DUE_DATE = TODAY’S DATE + (280 DAYS – 235 DAYS).
    # DON’T KNOW/REFUSED: ORIG_DUE_DATE = TODAY’S DATE + (280 DAYS – 140 DAYS)
    it "calculates the due date based on the 1st trimester" do
      take_survey(@survey, @response_set) do |a|
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.PREGNANT", ppg1
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_MM", neg_2
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_DD", neg_2
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_YY", neg_2
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_MM", neg_1
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_DD", neg_1
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_YY", neg_1
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.WEEKS_PREG", neg_2
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.MONTH_PREG", neg_2
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.TRIMESTER", tri1
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 10

      OperationalDataExtractor::PbsEligibilityScreener.extract_data(@response_set)

      person  = Person.find(@person.id)
      participant = person.participant
      participant.due_date.should == ((Date.today + 280.days) - (46.days)).to_date

    end

    it "calculates the due date based on the 2nd trimester" do
      take_survey(@survey, @response_set) do |a|
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.PREGNANT", ppg1
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_MM", neg_2
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_DD", neg_2
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_YY", neg_2
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_MM", neg_1
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_DD", neg_1
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_YY", neg_1
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.WEEKS_PREG", neg_2
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.MONTH_PREG", neg_2
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.TRIMESTER", tri2
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 10

      OperationalDataExtractor::PbsEligibilityScreener.extract_data(@response_set)

      person  = Person.find(@person.id)
      participant = person.participant
      participant.due_date.should == ((Date.today + 280.days) - (140.days)).to_date
    end

    it "calculates the due date based on the 3rd trimester" do
      take_survey(@survey, @response_set) do |a|
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.PREGNANT", ppg1
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_MM", neg_2
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_DD", neg_2
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_YY", neg_2
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_MM", neg_1
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_DD", neg_1
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_YY", neg_1
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.WEEKS_PREG", neg_2
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.MONTH_PREG", neg_2
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.TRIMESTER", tri3
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 10

      OperationalDataExtractor::PbsEligibilityScreener.extract_data(@response_set)

      person  = Person.find(@person.id)
      participant = person.participant
      participant.due_date.should == ((Date.today + 280.days) - (235.days)).to_date
    end

    it "calculates the due date when refused" do
      take_survey(@survey, @response_set) do |a|
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.PREGNANT", ppg1
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_MM", neg_2
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_DD", neg_2
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_YY", neg_2
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_MM", neg_1
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_DD", neg_1
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_YY", neg_1
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.WEEKS_PREG", neg_2
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.MONTH_PREG", neg_2
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.TRIMESTER", neg_2
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 10

      OperationalDataExtractor::PbsEligibilityScreener.extract_data(@response_set)

      person  = Person.find(@person.id)
      participant = person.participant
      participant.due_date.should == ((Date.today + 280.days) - (140.days)).to_date
    end

    it "calculates the due date when don't know" do
      take_survey(@survey, @response_set) do |a|
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.PREGNANT", ppg1
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_MM", neg_2
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_DD", neg_2
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_YY", neg_2
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_MM", neg_1
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_DD", neg_1
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_YY", neg_1
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.WEEKS_PREG", neg_2
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.MONTH_PREG", neg_2
        a.choice "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.TRIMESTER", neg_1
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 10

      OperationalDataExtractor::PbsEligibilityScreener.extract_data(@response_set)

      person  = Person.find(@person.id)
      participant = person.participant
      participant.due_date.should == ((Date.today + 280.days) - (140.days)).to_date
    end

  end

end