# -*- coding: utf-8 -*-


require 'spec_helper'

describe PregnancyScreenerOperationalDataExtractor do
  include SurveyCompletion

  context "extracting person operational data" do

    let(:age_range)      { NcsCode.for_list_name_and_local_code("AGE_RANGE_CL1", 3) }
    let(:ethnic_group)   { NcsCode.for_list_name_and_local_code("ETHNICITY_CL1", 2) }
    let(:language)       { NcsCode.for_list_name_and_local_code("LANGUAGE_CL2", 1) }
    let(:age_eligible)   { NcsCode.for_list_name_and_local_code("AGE_ELIGIBLE_CL2", 1) }
    let(:entered_age)    { 30 }

    before(:each) do
      @person = Factory(:person)
      @participant = Factory(:participant)
      @participant.person = @person
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
      response_set, instrument = prepare_instrument(@person, @survey)
      response_set.save!

      take_survey(@survey, response_set) do |a|
        a.str "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.R_FNAME", 'Jo'
        a.str "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.R_LNAME", 'Stafford'
        a.date "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.PERSON_DOB", '01/01/1981'
        a.int "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.AGE", entered_age
        a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.AGE_RANGE", age_range
        a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.ETHNICITY", ethnic_group
        a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.PERSON_LANG", language
        a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.AGE_ELIG", age_eligible
      end

      response_set.responses.reload
      response_set.responses.size.should == 8

      PregnancyScreenerOperationalDataExtractor.extract_data(response_set)

      person = Person.find(@person.id)
      person.first_name.should == "Jo"
      person.last_name.should == "Stafford"
      person.person_dob.should == "1981-01-01"

      expected_age = Date.today.year - 1981
      person.computed_age.should == expected_age
      person.age.should == entered_age

      person.age_range.should == age_range
      person.ethnic_group.should == ethnic_group
      person.language.should == language

      person.participant.pid_age_eligibility.display_text.should == age_eligible.display_text
      person.participant.pid_age_eligibility.local_code.should == age_eligible.local_code
    end

    describe "parsing datetime values" do

      it "handles YYYY-MM-DD" do
        entered_dob = "1981-01-11"
        response_set, instrument = prepare_instrument(@person, @survey)
        response_set.save!

        take_survey(@survey, response_set) do |a|
          a.date "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.PERSON_DOB", entered_dob
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
        response_set, instrument = prepare_instrument(@person, @survey)
        response_set.save!

        take_survey(@survey, response_set) do |a|
          a.date "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.PERSON_DOB", entered_dob
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
    state = NcsCode.for_list_name_and_local_code("STATE_CL1", 14)

    person = Factory(:person)
    person.addresses.size.should == 0

    survey = create_pregnancy_screener_survey_with_address_operational_data
    response_set, instrument = prepare_instrument(person, survey)
    response_set.save!

    take_survey(survey, response_set) do |a|
      a.str "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.ADDRESS_1", '123 Easy St.'
      a.str "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.ADDRESS_2", ''
      a.str "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.UNIT", ''
      a.str "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.CITY", 'Chicago'
      a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.STATE", state
      a.str "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.ZIP", '65432'
      a.str "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.ZIP4", '1234'
    end

    response_set.responses.reload
    response_set.responses.size.should == 7

    PregnancyScreenerOperationalDataExtractor.extract_data(response_set)

    person = Person.find(person.id)
    person.addresses.size.should == 1
    address = person.addresses.first
    address.to_s.should == "123 Easy St. Chicago, ILLINOIS 65432-1234"
    address.address_rank_code.should == 1
  end

  it "extracts mail address operational data from the survey responses" do

    state = NcsCode.for_list_name_and_local_code("STATE_CL1", 14)
    home = NcsCode.for_list_name_and_local_code("ADDRESS_CATEGORY_CL1", 1)
    mail = NcsCode.for_list_name_and_local_code("ADDRESS_CATEGORY_CL1", 4)

    person = Factory(:person)
    person.addresses.size.should == 0

    survey = create_pregnancy_screener_survey_with_mail_address_operational_data
    response_set, instrument = prepare_instrument(person, survey)
    response_set.save!

    take_survey(survey, response_set) do |a|
      a.str "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.MAIL_ADDRESS_1", '123 Easy St.'
      a.str "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.MAIL_ADDRESS_2", ''
      a.str "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.MAIL_UNIT", ''
      a.str "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.MAIL_CITY", 'Chicago'
      a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.MAIL_STATE", state
      a.str "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.MAIL_ZIP", '65432'
      a.str "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.MAIL_ZIP4", '1234'
    end

    response_set.responses.reload
    response_set.responses.size.should == 7

    PregnancyScreenerOperationalDataExtractor.extract_data(response_set)

    person  = Person.find(person.id)
    person.addresses.size.should == 1
    address = person.addresses.first
    address.to_s.should == "123 Easy St. Chicago, ILLINOIS 65432-1234"
    address.address_type.should == mail
    address.address_rank_code.should == 1
  end

  context "extracting telephone operational data from the survey responses" do

    let(:home) { NcsCode.for_list_name_and_local_code("PHONE_TYPE_CL1", 1) }
    let(:work) { NcsCode.for_list_name_and_local_code("PHONE_TYPE_CL1", 2) }
    let(:cell) { NcsCode.for_list_name_and_local_code("PHONE_TYPE_CL1", 3) }
    let(:frre) { NcsCode.for_list_name_and_local_code("PHONE_TYPE_CL1", 4) }
    let(:fax)  { NcsCode.for_list_name_and_local_code("PHONE_TYPE_CL1", 5) }
    let(:oth)  { NcsCode.for_list_name_and_local_code("PHONE_TYPE_CL1", -5) }

    before(:each) do
      @person = Factory(:person)
      @person.telephones.size.should == 0

      @survey = create_pregnancy_screener_survey_with_telephone_operational_data
    end

    it "extracts telephone operational data" do
      response_set, instrument = prepare_instrument(@person, @survey)
      response_set.save!

      take_survey(@survey, response_set) do |a|
        a.str "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.PHONE_NBR", '3125551234'
        a.str "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.PHONE_NBR_OTH", ''
        a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.PHONE_TYPE", cell
        a.str "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.PHONE_TYPE_OTH", ''
        a.str "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.HOME_PHONE", '3125554321'
        a.yes "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.CELL_PHONE_2"
        a.yes "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.CELL_PHONE_4"
        a.str "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.CELL_PHONE", '3125557890'
      end

      response_set.responses.reload
      response_set.responses.size.should == 8

      PregnancyScreenerOperationalDataExtractor.extract_data(response_set)

      person  = Person.find(@person.id)
      person.telephones.size.should == 3
      person.telephones.each do |t|
        t.phone_type.should_not be_nil
        t.phone_nbr[0,6].should == "312555"
        t.phone_rank_code.should == 1
      end

    end

    describe "handling various telephone formats" do

      it "handles xxx.xxx.xxxx" do
        response_set, instrument = prepare_instrument(@person, @survey)
        response_set.save!

        take_survey(@survey, response_set) do |a|
          a.str "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.PHONE_NBR", '312.555.1234'
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
        response_set, instrument = prepare_instrument(@person, @survey)
        response_set.save!

        take_survey(@survey, response_set) do |a|
          a.str "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.PHONE_NBR", '(312) 555-1234'
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
        response_set, instrument = prepare_instrument(@person, @survey)
        response_set.save!

        take_survey(@survey, response_set) do |a|
          a.str "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.PHONE_NBR", '(312) 5551234'
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
        response_set, instrument = prepare_instrument(@person, @survey)
        response_set.save!

        take_survey(@survey, response_set) do |a|
          a.str "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.PHONE_NBR", '312-555-1234'
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

    home = NcsCode.for_list_name_and_local_code("EMAIL_TYPE_CL1", 1)
    work = NcsCode.for_list_name_and_local_code("EMAIL_TYPE_CL1", 2)

    person = Factory(:person)
    person.emails.size.should == 0

    survey = create_pregnancy_screener_survey_with_email_operational_data
    response_set, instrument = prepare_instrument(person, survey)
    response_set.save!

    take_survey(survey, response_set) do |a|
      a.str "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.EMAIL", 'email@dev.null'
      a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.EMAIL_TYPE", home
    end

    response_set.responses.reload
    response_set.responses.size.should == 2

    PregnancyScreenerOperationalDataExtractor.extract_data(response_set)

    person  = Person.find(person.id)
    person.emails.size.should == 1
    person.emails.first.email.should == "email@dev.null"
    person.emails.first.email_type.local_code.should == 1
    person.emails.first.email_rank_code.should == 1

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
    participant = Factory(:participant)
    ppl = Factory(:participant_person_link, :participant => participant, :person => person)

    ppg1 = NcsCode.for_list_name_and_local_code("PPG_STATUS_CL2", 1)

    p_type = NcsCode.for_list_name_and_local_code("PARTICIPANT_TYPE_CL1", 3)

    survey = create_pregnancy_screener_survey_with_ppg_detail_operational_data
    response_set, instrument = prepare_instrument(person, survey)
    response_set.save!

    take_survey(survey, response_set) do |a|
      a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.PREGNANT", ppg1
      a.date "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.ORIG_DUE_DATE", '2011-12-25'
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
    participant.p_type.should == p_type

  end

  it "sets the ppg detail ppg status to 2 if the person responds that they are trying to become pregnant" do

    person = Factory(:person)
    participant = Factory(:participant)
    ppl = Factory(:participant_person_link, :participant => participant, :person => person)

    ppg2 = NcsCode.for_list_name_and_local_code("PPG_STATUS_CL2", 2)

    p_type = NcsCode.for_list_name_and_local_code("PARTICIPANT_TYPE_CL1", 2)

    survey = create_pregnancy_screener_survey_with_ppg_detail_operational_data
    response_set, instrument = prepare_instrument(person, survey)
    response_set.save!

    take_survey(survey, response_set) do |a|
      a.yes "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.TRYING"
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
    participant.p_type.should == p_type

  end

  it "sets the ppg detail ppg status to 5 if the person responds that they are unable to become pregnant" do

    person = Factory(:person)
    participant = Factory(:participant)
    ppl = Factory(:participant_person_link, :participant => participant, :person => person)

    ppg5 = NcsCode.for_list_name_and_local_code("PPG_STATUS_CL2", 5)

    survey = create_pregnancy_screener_survey_with_ppg_detail_operational_data
    response_set, instrument = prepare_instrument(person, survey)
    response_set.save!

    take_survey(survey, response_set) do |a|
      a.yes "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.HYSTER"
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

      @survey = create_pregnancy_screener_survey_to_determine_due_date

      @response_set, @instrument = prepare_instrument(@person, @survey)
      @response_set.save!
    end

    it "sets the due date to the date provided by the participant" do

      due_date = "2012-02-29"

      take_survey(@survey, @response_set) do |a|
        a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.PREGNANT", ppg1
        a.date "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.ORIG_DUE_DATE", due_date
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

      take_survey(@survey, @response_set) do |a|
        a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.PREGNANT", ppg1
        a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.ORIG_DUE_DATE", neg_2
        a.date "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.DATE_PERIOD", last_period
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

      take_survey(@survey, @response_set) do |a|
        a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.PREGNANT", ppg1
        a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.ORIG_DUE_DATE", neg_2
        a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.DATE_PERIOD", neg_2
        a.int "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.WEEKS_PREG", weeks_pregnant
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

      take_survey(@survey, @response_set) do |a|
        a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.PREGNANT", ppg1
        a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.ORIG_DUE_DATE", neg_2
        a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.DATE_PERIOD", neg_2
        a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.WEEKS_PREG", neg_2
        a.int "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.MONTH_PREG", months_pregnant
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
      take_survey(@survey, @response_set) do |a|
        a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.PREGNANT", ppg1
        a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.ORIG_DUE_DATE", neg_2
        a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.DATE_PERIOD", neg_2
        a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.WEEKS_PREG", neg_2
        a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.MONTH_PREG", neg_2
        a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.TRIMESTER", tri1
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 6

      PregnancyScreenerOperationalDataExtractor.extract_data(@response_set)

      person  = Person.find(@person.id)
      participant = person.participant
      participant.due_date.should == ((Date.today + 280.days) - (46.days)).to_date

    end

    it "calculates the due date based on the 2nd trimester" do
      take_survey(@survey, @response_set) do |a|
        a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.PREGNANT", ppg1
        a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.ORIG_DUE_DATE", neg_2
        a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.DATE_PERIOD", neg_2
        a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.WEEKS_PREG", neg_2
        a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.MONTH_PREG", neg_2
        a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.TRIMESTER", tri2
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 6

      PregnancyScreenerOperationalDataExtractor.extract_data(@response_set)

      person  = Person.find(@person.id)
      participant = person.participant
      participant.due_date.should == ((Date.today + 280.days) - (140.days)).to_date
    end

    it "calculates the due date based on the 3rd trimester" do
      take_survey(@survey, @response_set) do |a|
        a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.PREGNANT", ppg1
        a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.ORIG_DUE_DATE", neg_2
        a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.DATE_PERIOD", neg_2
        a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.WEEKS_PREG", neg_2
        a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.MONTH_PREG", neg_2
        a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.TRIMESTER", tri3
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 6

      PregnancyScreenerOperationalDataExtractor.extract_data(@response_set)

      person  = Person.find(@person.id)
      participant = person.participant
      participant.due_date.should == ((Date.today + 280.days) - (235.days)).to_date
    end

    it "calculates the due date when refused" do
      take_survey(@survey, @response_set) do |a|
        a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.PREGNANT", ppg1
        a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.ORIG_DUE_DATE", neg_2
        a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.DATE_PERIOD", neg_2
        a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.WEEKS_PREG", neg_2
        a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.MONTH_PREG", neg_2
        a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.TRIMESTER", neg_2
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 6

      PregnancyScreenerOperationalDataExtractor.extract_data(@response_set)

      person  = Person.find(@person.id)
      participant = person.participant
      participant.due_date.should == ((Date.today + 280.days) - (140.days)).to_date
    end

    it "calculates the due date when don't know" do
      take_survey(@survey, @response_set) do |a|
        a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.PREGNANT", ppg1
        a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.ORIG_DUE_DATE", neg_2
        a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.DATE_PERIOD", neg_2
        a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.WEEKS_PREG", neg_2
        a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.MONTH_PREG", neg_2
        a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.TRIMESTER", neg_1
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
