# -*- coding: utf-8 -*-


require 'spec_helper'

require File.expand_path('../../../shared/custom_recruitment_strategy', __FILE__)

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
      @participant.save!
      @survey = create_pbs_eligibility_screener_survey_with_person_operational_data
    end

    it "extracts person operational data from the survey responses" do
      response_set, instrument = prepare_instrument(@person, @participant, @survey)
      response_set.save!

      take_survey(@survey, response_set) do |r|
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.R_FNAME", 'Jo'
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.R_MNAME", 'Anna'
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.R_LNAME", 'Stafford'
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.PERSON_DOB", '01/01/1981'
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.AGE_RANGE_PBS", age_range
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ETHNIC_ORIGIN", ethnic_group
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.PERSON_LANG_NEW", language
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.AGE_ELIG", age_eligible
      end

      response_set.responses.reload
      response_set.responses.size.should == 8

      OperationalDataExtractor::PbsEligibilityScreener.new(response_set).extract_data

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

      take_survey(@survey, response_set) do |r|
        r.refused "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.R_FNAME"
        r.refused "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.R_MNAME"
        r.refused "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.R_LNAME"
        r.dont_know "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.PERSON_DOB"
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.AGE_RANGE_PBS", age_range_refused
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ETHNIC_ORIGIN", ethnic_group_refused
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.PERSON_LANG_NEW", language
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.AGE_ELIG", age_eligible
      end

      response_set.responses.reload
      response_set.responses.size.should == 8

      OperationalDataExtractor::PbsEligibilityScreener.new(response_set).extract_data

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

      take_survey(survey, response_set) do |r|
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ADDRESS_1", '123 Easy St.'
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ADDRESS_2", ''
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.UNIT", ''
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.CITY", 'Chicago'
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.STATE", state
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ZIP", '65432'
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ZIP4", '1234'
      end

      response_set.responses.reload
      response_set.responses.size.should == 7

      OperationalDataExtractor::PbsEligibilityScreener.new(response_set).extract_data

      person = Person.find(person.id)
      person.addresses.size.should == 1
      address = person.addresses.first
      address.to_s.should == "123 Easy St. Chicago, Illinois 65432-1234"
      address.address_rank_code.should == 1
    end

    it "extracts operational data from the hospital survey responses" do
      state = NcsCode.for_list_name_and_local_code("STATE_CL1", 14)
      person = Factory(:person)
      participant = Factory(:participant)
      survey = create_hospital_eligibility_screener_survey_with_address_operational_data

      person.addresses.size.should == 0
      response_set, instrument = prepare_instrument(person, participant, survey)
      response_set.save!

      take_survey(survey, response_set) do |r|
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::HOSPITAL_INTERVIEW_PREFIX}.ADDRESS_1", '123 Easy St.'
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::HOSPITAL_INTERVIEW_PREFIX}.ADDRESS_2", ''
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::HOSPITAL_INTERVIEW_PREFIX}.UNIT", ''
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::HOSPITAL_INTERVIEW_PREFIX}.CITY", 'Chicago'
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::HOSPITAL_INTERVIEW_PREFIX}.STATE", state
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::HOSPITAL_INTERVIEW_PREFIX}.ZIP", '65432'
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::HOSPITAL_INTERVIEW_PREFIX}.ZIP4", '1234'
      end

      response_set.responses.reload
      response_set.responses.size.should == 7

      OperationalDataExtractor::PbsEligibilityScreener.new(response_set).extract_data

      person = Person.find(person.id)
      person.addresses.size.should == 1
      address = person.addresses.first
      address.to_s.should == "123 Easy St. Chicago, Illinois 65432-1234"
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

      take_survey(survey, response_set) do |r|
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ADDRESS_1", '123 Easy St.'
        r.refused "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ADDRESS_2"
        r.dont_know "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.UNIT"
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.CITY", 'Chicago'
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.STATE", state
        r.refused "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ZIP"
        r.dont_know "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ZIP4"
      end

      response_set.responses.reload
      response_set.responses.size.should == 7

      OperationalDataExtractor::PbsEligibilityScreener.new(response_set).extract_data

      person = Person.find(person.id)
      person.addresses.size.should == 1
      address = person.addresses.first
      address.to_s.should == "123 Easy St. Chicago, Illinois"
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

      take_survey(survey, response_set) do |r|
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ADDRESS_1", '123 Easy St.'
        r.refused "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ADDRESS_2"
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.UNIT", "123456789987654321"
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.CITY", 'Chicago'
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.STATE", state
        r.refused "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ZIP"
        r.dont_know "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ZIP4"
      end

      response_set.responses.reload
      response_set.responses.size.should == 7

      OperationalDataExtractor::PbsEligibilityScreener.new(response_set).extract_data

      person = Person.find(person.id)
      person.addresses.size.should == 1
      address = person.addresses.first
      address.to_s.should == "123 Easy St. Chicago, Illinois"
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

      take_survey(@survey, response_set) do |r|
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.R_PHONE_1", '3125551234'
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.R_PHONE_TYPE1", home
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.R_PHONE_TYPE1_OTH", ''
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.R_PHONE_2", '3125554321'
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.R_PHONE_TYPE2", cell
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.R_PHONE_TYPE2_OTH", ''
      end

      response_set.responses.reload
      response_set.responses.size.should == 6

      OperationalDataExtractor::PbsEligibilityScreener.new(response_set).extract_data

      person  = Person.find(@person.id)
      person.telephones.size.should == 2
      person.telephones.each do |t|
        t.phone_type.should_not be_nil
        t.phone_nbr[0,6].should == "312555"
      end

      person.telephones.first.phone_rank_code.should == 1
      person.telephones.last.phone_rank_code.should == 2
    end
  end

  it "extracts email information from the survey responses" do

    person = Factory(:person)
    person.emails.size.should == 0

    participant = Factory(:participant)
    survey = create_pbs_eligibility_screener_survey_with_email_operational_data
    response_set, instrument = prepare_instrument(person, participant, survey)
    response_set.save!

    take_survey(survey, response_set) do |r|
      r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.R_EMAIL", 'email@dev.null'
    end

    response_set.responses.reload
    response_set.responses.size.should == 1

    OperationalDataExtractor::PbsEligibilityScreener.new(response_set).extract_data

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

    take_survey(survey, response_set) do |r|
      r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.PREGNANT", ppg1
    end

    response_set.responses.reload
    response_set.responses.size.should == 1

    OperationalDataExtractor::PbsEligibilityScreener.new(response_set).extract_data

    person  = Person.find(person.id)
    participant = person.participant
    participant.ppg_details.size.should == 1
    participant.ppg_details.first.ppg_first.local_code.should == 1
    participant.ppg_status.local_code.should == 1
    participant.p_type.should == p_type
  end

  describe "determine_pregnant_participant_type" do

    let(:ppg1) {NcsCode.for_list_name_and_local_code("PPG_STATUS_CL2", 1)}
    let(:survey) {create_pbs_eligibility_screener_survey_with_ppg_detail_operational_data}

    context "for the PBS protocol" do

      # TODO: determine why these MDES 3.2 codes are not in the code list when running the specs
      before do
        NcsCode.create!(:list_name => "PARTICIPANT_TYPE_CL1", :local_code => 14, :display_text => "PBS Provider Participant")
        NcsCode.create!(:list_name => "PARTICIPANT_TYPE_CL1", :local_code => 15, :display_text => "PBS Hospital Participant")
      end

      include_context 'custom recruitment strategy'

      let(:recruitment_strategy) { ProviderBasedSubsample.new }

      let(:version) { NcsNavigator::Core::Mdes::Version.new('3.2') }

      around do |example|
        begin
          old_version = NcsNavigatorCore.mdes_version
          NcsNavigatorCore.mdes_version = version
          example.call
        ensure
          NcsNavigatorCore.mdes_version = old_version
        end
      end

      describe "for a participant whose provider is a hospital" do
        it "sets the participant type to PBS Hospital Participant" do
          person = Factory(:person)
          participant = Factory(:participant)
          participant.person = person
          participant.save!

          Participant.any_instance.stub(:birth_cohort?).and_return(true)

          response_set, instrument = prepare_instrument(person, participant, survey)
          response_set.save!
          take_survey(survey, response_set) do |r|
            r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.PREGNANT", ppg1
          end
          response_set.responses.reload
          OperationalDataExtractor::PbsEligibilityScreener.new(response_set).extract_data
          participant = Participant.find(participant.id)
          # 15 PBS Hospital Participant
          participant.p_type_code.should == 15
        end
      end

      describe "for a participant whose provider is NOT a hospital" do
        it "sets the participant type to PBS Hospital Participant" do
          person = Factory(:person)
          participant = Factory(:participant)
          participant.person = person
          participant.save!

          Participant.any_instance.stub(:birth_cohort?).and_return(false)

          response_set, instrument = prepare_instrument(person, participant, survey)
          response_set.save!
          take_survey(survey, response_set) do |r|
            r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.PREGNANT", ppg1
          end
          response_set.responses.reload
          OperationalDataExtractor::PbsEligibilityScreener.new(response_set).extract_data
          participant = Participant.find(participant.id)
          # 14 PBS Hospital Participant
          participant.p_type_code.should == 14
        end
      end

    end


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

    take_survey(survey, response_set) do |r|
      r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.PREGNANT", ppg2
    end

    response_set.responses.reload
    response_set.responses.size.should == 1

    OperationalDataExtractor::PbsEligibilityScreener.new(response_set).extract_data

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

    take_survey(survey, response_set) do |r|
      r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.PREGNANT", ppg5
    end

    response_set.responses.reload
    response_set.responses.size.should == 1

    OperationalDataExtractor::PbsEligibilityScreener.new(response_set).extract_data

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
      take_survey(@survey, @response_set) do |r|
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.PREGNANT", ppg1
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_MM", mock_model(NcsCode, :local_code => due_date.month)
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_DD", due_date.day
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_YY", due_date.year
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 4

      OperationalDataExtractor::PbsEligibilityScreener.new(@response_set).extract_data

      person  = Person.find(@person.id)
      participant = person.participant
      participant.due_date.should == due_date
    end

    it "does not set the due date if the format of the day is not two digits" do
      take_survey(@survey, @response_set) do |r|
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.PREGNANT", ppg1
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_MM", mock_model(NcsCode, :local_code => 2)
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_DD", "First"
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_YY", "2525"
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 4

      OperationalDataExtractor::PbsEligibilityScreener.new(@response_set).extract_data

      person  = Person.find(@person.id)
      participant = person.participant
      participant.due_date.should be_nil
    end

    it "does not set the due date if the format of the year is not four digits" do
      take_survey(@survey, @response_set) do |r|
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.PREGNANT", ppg1
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_MM", mock_model(NcsCode, :local_code => 2)
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_DD", "02"
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_YY", "2525 CE"
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 4

      OperationalDataExtractor::PbsEligibilityScreener.new(@response_set).extract_data

      person  = Person.find(@person.id)
      participant = person.participant
      participant.due_date.should be_nil
    end

    # # CALCULATE DUE DATE FROM THE FIRST DATE OF LAST MENSTRUAL PERIOD AND SET ORIG_DUE_DATE = DATE_PERIOD + 280 DAYS
    it "calculates the due date based on the date of the last menstrual period" do

      last_period = 20.weeks.ago

      take_survey(@survey, @response_set) do |r|
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.PREGNANT", ppg1
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_MM", neg_2
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_DD", neg_2
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_YY", neg_2
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_MM", mock(NcsCode, :local_code => last_period.month)
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_DD", last_period.day
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_YY", last_period.year
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 7

      OperationalDataExtractor::PbsEligibilityScreener.new(@response_set).extract_data

      person  = Person.find(@person.id)
      participant = person.participant
      participant.due_date.should == (last_period + 280.days).to_date

    end

    # CALCULATE ORIG_DUE_DATE =TODAY’S DATE + 280 DAYS – WEEKS_PREG * 7
    it "calculates the due date based on the number of weeks pregnant" do

      weeks_pregnant = 8

      take_survey(@survey, @response_set) do |r|
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.PREGNANT", ppg1
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_MM", neg_2
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_DD", neg_2
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_YY", neg_2
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_MM", neg_1
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_DD", neg_1
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_YY", neg_1
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.WEEKS_PREG", weeks_pregnant
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 8

      OperationalDataExtractor::PbsEligibilityScreener.new(@response_set).extract_data

      person  = Person.find(@person.id)
      participant = person.participant
      participant.due_date.should == ((Date.today + 280.days) - (weeks_pregnant * 7)).to_date

    end

    # CALCULATE DUE DATE AS FROM NUMBER OF MONTHS PREGNANT WHERE ORIG_DUE_DATE =TODAY’S DATE + 280 DAYS – MONTH_PREG * 30 - 15
    it "calculates the due date based on the number of months pregnant" do
      months_pregnant = 4

      take_survey(@survey, @response_set) do |r|
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.PREGNANT", ppg1
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_MM", neg_2
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_DD", neg_2
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_YY", neg_2
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_MM", neg_1
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_DD", neg_1
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_YY", neg_1
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.WEEKS_PREG", neg_2
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.MONTH_PREG", months_pregnant
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 9

      OperationalDataExtractor::PbsEligibilityScreener.new(@response_set).extract_data

      person  = Person.find(@person.id)
      participant = person.participant
      participant.due_date.should == ((Date.today + 280.days) - ((months_pregnant * 30) - 15)).to_date

    end

    # 1ST TRIMESTER:      ORIG_DUE_DATE = TODAY’S DATE + (280 DAYS – 46 DAYS).
    # 2ND TRIMESTER:      ORIG_DUE_DATE = TODAY’S DATE + (280 DAYS – 140 DAYS).
    # 3RD TRIMESTER:      ORIG_DUE_DATE = TODAY’S DATE + (280 DAYS – 235 DAYS).
    # DON’T KNOW/REFUSED: ORIG_DUE_DATE = TODAY’S DATE + (280 DAYS – 140 DAYS)
    it "calculates the due date based on the 1st trimester" do
      take_survey(@survey, @response_set) do |r|
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.PREGNANT", ppg1
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_MM", neg_2
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_DD", neg_2
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_YY", neg_2
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_MM", neg_1
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_DD", neg_1
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_YY", neg_1
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.WEEKS_PREG", neg_2
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.MONTH_PREG", neg_2
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.TRIMESTER", tri1
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 10

      OperationalDataExtractor::PbsEligibilityScreener.new(@response_set).extract_data

      person  = Person.find(@person.id)
      participant = person.participant
      participant.due_date.should == ((Date.today + 280.days) - (46.days)).to_date

    end

    it "calculates the due date based on the 2nd trimester" do
      take_survey(@survey, @response_set) do |r|
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.PREGNANT", ppg1
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_MM", neg_2
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_DD", neg_2
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_YY", neg_2
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_MM", neg_1
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_DD", neg_1
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_YY", neg_1
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.WEEKS_PREG", neg_2
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.MONTH_PREG", neg_2
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.TRIMESTER", tri2
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 10

      OperationalDataExtractor::PbsEligibilityScreener.new(@response_set).extract_data

      person  = Person.find(@person.id)
      participant = person.participant
      participant.due_date.should == ((Date.today + 280.days) - (140.days)).to_date
    end

    it "calculates the due date based on the 3rd trimester" do
      take_survey(@survey, @response_set) do |r|
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.PREGNANT", ppg1
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_MM", neg_2
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_DD", neg_2
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_YY", neg_2
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_MM", neg_1
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_DD", neg_1
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_YY", neg_1
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.WEEKS_PREG", neg_2
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.MONTH_PREG", neg_2
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.TRIMESTER", tri3
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 10

      OperationalDataExtractor::PbsEligibilityScreener.new(@response_set).extract_data

      person  = Person.find(@person.id)
      participant = person.participant
      participant.due_date.should == ((Date.today + 280.days) - (235.days)).to_date
    end

    it "calculates the due date when refused" do
      take_survey(@survey, @response_set) do |r|
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.PREGNANT", ppg1
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_MM", neg_2
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_DD", neg_2
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_YY", neg_2
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_MM", neg_1
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_DD", neg_1
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_YY", neg_1
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.WEEKS_PREG", neg_2
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.MONTH_PREG", neg_2
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.TRIMESTER", neg_2
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 10

      OperationalDataExtractor::PbsEligibilityScreener.new(@response_set).extract_data

      person  = Person.find(@person.id)
      participant = person.participant
      participant.due_date.should == ((Date.today + 280.days) - (140.days)).to_date
    end

    it "calculates the due date when don't know" do
      take_survey(@survey, @response_set) do |r|
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.PREGNANT", ppg1
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_MM", neg_2
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_DD", neg_2
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_YY", neg_2
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_MM", neg_1
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_DD", neg_1
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_YY", neg_1
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.WEEKS_PREG", neg_2
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.MONTH_PREG", neg_2
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.TRIMESTER", neg_1
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 10

      OperationalDataExtractor::PbsEligibilityScreener.new(@response_set).extract_data

      person  = Person.find(@person.id)
      participant = person.participant
      participant.due_date.should == ((Date.today + 280.days) - (140.days)).to_date
    end

  end

  context "ensuring that the ODE processes regardless of response_set response ordering" do

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

    describe "#known_keys" do
      it "collects all the keys for the ODE maps" do
        ode = OperationalDataExtractor::PbsEligibilityScreener.new(@response_set)
        ode.known_keys.size.should == 53
      end
    end

    describe "#data_export_identifier_indexed_responses" do
      it "collects all the responses and maps them to their associated data_export_identifier" do
        last_period = 2.weeks.ago

        take_survey(@survey, @response_set) do |r|
          r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_YY", last_period.year
          r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_MM", mock(NcsCode, :local_code => last_period.month)
          r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_DD", last_period.day

          r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.PREGNANT", ppg1

          r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_DD", neg_2
          r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_MM", neg_2
          r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_YY", neg_2
        end

        @response_set.responses.reload

        ode = OperationalDataExtractor::PbsEligibilityScreener.new(@response_set)
        dei_hsh = ode.data_export_identifier_indexed_responses

        dei_hsh.size.should == 7
        dei_hsh["#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_DD"].string_value.should == last_period.day.to_s
        dei_hsh["#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.PREGNANT"].answer.reference_identifier.should == "1"
      end
    end

    it "calculates the due date based on the date of the last menstrual period" do

      last_period = 20.weeks.ago

      take_survey(@survey, @response_set) do |r|
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_YY", last_period.year
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_MM", mock(NcsCode, :local_code => last_period.month)
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.DATE_PERIOD_DD", last_period.day

        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.PREGNANT", ppg1

        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_DD", neg_2
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_MM", neg_2
        r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.ORIG_DUE_DATE_YY", neg_2
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 7

      OperationalDataExtractor::PbsEligibilityScreener.new(@response_set).extract_data

      person  = Person.find(@person.id)
      participant = person.participant
      participant.due_date.should == (last_period + 280.days).to_date

    end

  end

  context "setting instrument administration mode" do

    let(:person) { Factory(:person) }
    let(:survey) { create_pbs_eligibility_screener_survey_with_prepopulated_questions }

    before(:each) do
      @participant = Factory(:participant)
      @participant.person = person
      @participant.save!

      @response_set, @instrument = prepare_instrument(person, @participant, survey, Instrument.cati)
    end

    it "sets the mode to CAPI" do
      take_survey(survey, @response_set) do |r|
        r.a "prepopulated_mode_of_contact", mock(NcsCode, :local_code => "capi")
      end
      OperationalDataExtractor::PbsEligibilityScreener.new(@response_set).extract_data
      Instrument.find(@instrument.id).instrument_mode_code.should == Instrument.capi
    end

    it "sets the mode to CATI" do
      take_survey(survey, @response_set) do |r|
        r.a "prepopulated_mode_of_contact", mock(NcsCode, :local_code => "cati")
      end
      OperationalDataExtractor::PbsEligibilityScreener.new(@response_set).extract_data
      Instrument.find(@instrument.id).instrument_mode_code.should == Instrument.cati
    end

    it "sets the mode to PAPI" do
      take_survey(survey, @response_set) do |r|
        r.a "prepopulated_mode_of_contact", mock(NcsCode, :local_code => "papi")
      end
      OperationalDataExtractor::PbsEligibilityScreener.new(@response_set).extract_data
      Instrument.find(@instrument.id).instrument_mode_code.should == Instrument.papi
    end

  end

  context "extracting race operational data" do

    let(:white_race) { NcsCode.for_list_name_and_local_code("RACE_CL1", 1) }
    let(:black_race) { NcsCode.for_list_name_and_local_code("RACE_CL1", 2) }
    let(:asian_race) { NcsCode.for_list_name_and_local_code("RACE_CL1", 4) }
    let(:pacific_islander_race) { NcsCode.for_list_name_and_local_code("RACE_CL1", 5) }
    let(:other_race) { NcsCode.for_list_name_and_local_code("RACE_CL1", -5) }
    let(:vietnamese_race) { NcsCode.for_list_name_and_local_code("RACE_CL6", 9) } # new-type vietnamese (differing race code list)
    let(:filipino_race) { NcsCode.for_list_name_and_local_code("RACE_CL7", 3) }
    let(:asian_indian_race) { NcsCode.for_list_name_and_local_code("RACE_CL7", 1) }
    let(:samoan_race) { NcsCode.for_list_name_and_local_code("RACE_CL8", 3) }
    let(:native_hawaiian_race) { NcsCode.for_list_name_and_local_code("RACE_CL8", 1) }

    before do
      @person = Factory(:person)
      participant = Factory(:participant)
      Factory(:participant_person_link, :participant => participant, :person => @person)
      @survey = create_pbs_eligibility_screener_survey_with_person_race_operational_data
      @response_set, instrument = prepare_instrument(@person, participant, @survey)
    end

    describe "processing standard racial data" do
      before do
        take_survey(@survey, @response_set) do |r|
          r.a "#{OperationalDataExtractor::PbsEligibilityScreener::PBS_ELIG_SCREENER_RACE_1_PREFIX}.RACE_1", black_race
          r.a "#{OperationalDataExtractor::PbsEligibilityScreener::PBS_ELIG_SCREENER_RACE_1_PREFIX}.RACE_1", other_race
          r.a "#{OperationalDataExtractor::PbsEligibilityScreener::PBS_ELIG_SCREENER_RACE_1_PREFIX}.RACE_1_OTH", "Aborigine"
        end

        OperationalDataExtractor::PbsEligibilityScreener.new(@response_set).extract_data
      end

      it "extracts two standard racial data" do
        @person.races.should have(2).races
      end

      it "creates at least one race record with a specific non-other code" do
        @person.races.map(&:race_code).should include(black_race.local_code)
      end

      it "creates at least one race record with an other code" do
        @person.races.map(&:race_code).should include(other_race.local_code)
      end

      it "creates an other code with the text 'Aborigine'" do
        @person.races.map(&:race_other).should include("Aborigine")
      end
    end

    describe "processing new type racial data" do
      before do
        take_survey(@survey, @response_set) do |r|
          r.a "#{OperationalDataExtractor::PbsEligibilityScreener::PBS_ELIG_SCREENER_RACE_NEW_PREFIX}.RACE_NEW", white_race
          r.a "#{OperationalDataExtractor::PbsEligibilityScreener::PBS_ELIG_SCREENER_RACE_NEW_PREFIX}.RACE_NEW", vietnamese_race
        end

        OperationalDataExtractor::PbsEligibilityScreener.new(@response_set).extract_data
      end

      it "extracts a two new type racial data" do
        @person.races.should have(2).races
      end

      it "the record with an answer on the standard race code list is represented as a simple code" do
        @person.races.map(&:race_code).should include(white_race.local_code)
      end

      it "the record generated from a response that is NOT on the standard race code list is represented with a code for 'other' (-5)" do
        @person.races.map(&:race_code).should include(other_race.local_code)
      end

      it "the record generated from a response that is NOT on the standard race code list should have the text associated with the choice in the 'race_other' attribute" do
        other_race_record = @person.races.detect { |race| race.race_code == other_race.local_code }
        other_race_record.race_other.should == "Vietnamese"
      end

      it "does not create duplicate entries when data is extracted multiple times" do
        10.times do
          OperationalDataExtractor::PbsEligibilityScreener.new(@response_set).extract_data
        end

        PersonRace.count.should == 2
      end
    end

    describe "processing with multiple specific asian records" do
      before do
        take_survey(@survey, @response_set) do |r|
          r.a "#{OperationalDataExtractor::PbsEligibilityScreener::PBS_ELIG_SCREENER_RACE_1_PREFIX}.RACE_1", asian_race
          r.a "#{OperationalDataExtractor::PbsEligibilityScreener::PBS_ELIG_SCREENER_RACE_2_PREFIX}.RACE_2", filipino_race
          r.a "#{OperationalDataExtractor::PbsEligibilityScreener::PBS_ELIG_SCREENER_RACE_2_PREFIX}.RACE_2", asian_indian_race
        end

        OperationalDataExtractor::PbsEligibilityScreener.new(@response_set).extract_data
      end

      it "extracts three racial data" do
        PersonRace.count.should == 3
      end

      it "the base asian race classification is stored in race_code as the local code of its code list value" do
        @person.races.select { |race| race.race_code == asian_race.local_code }.size.should == 1
      end

      it "the more specific asian races should have a race_code of 'other' (-5)" do
        @person.races.select { |race| race.race_code == other_race.local_code }.size.should == 2
      end

      it "the more specific asian races should have a race_other of the text of their race" do
         @person.races.one? { |race| race.race_other == "Asian Indian" }.should be_true
         @person.races.one? { |race| race.race_other == "Filipino" }.should be_true
      end
    end

    describe "processing with multiple specific pacific islander records" do
      before do
        take_survey(@survey, @response_set) do |r|
          r.a "#{OperationalDataExtractor::PbsEligibilityScreener::PBS_ELIG_SCREENER_RACE_1_PREFIX}.RACE_1", pacific_islander_race
          r.a "#{OperationalDataExtractor::PbsEligibilityScreener::PBS_ELIG_SCREENER_RACE_3_PREFIX}.RACE_3", samoan_race
          r.a "#{OperationalDataExtractor::PbsEligibilityScreener::PBS_ELIG_SCREENER_RACE_3_PREFIX}.RACE_3", native_hawaiian_race
        end

        OperationalDataExtractor::PbsEligibilityScreener.new(@response_set).extract_data
      end

      it "extracts three racial data" do
        PersonRace.count.should == 3
      end

      it "the base pacific islander race classification is stored in race_code as the local code of its code list value" do
        @person.races.select { |race| race.race_code == pacific_islander_race.local_code }.size.should == 1
      end

      it "the more specific pacific islander races should have a race_code of 'other' (-5)" do
        @person.races.select { |race| race.race_code == other_race.local_code }.size.should == 2
      end

      it "the more specific pacific islander races should have a race_other of the text of their race" do
         @person.races.one? { |race| race.race_other == "Samoan" }.should be_true
         @person.races.one? { |race| race.race_other == "Native Hawaiian" }.should be_true
      end

      it "does not create duplicate entries when data is extracted multiple times" do
        10.times do
          OperationalDataExtractor::PbsEligibilityScreener.new(@response_set).extract_data
        end

        PersonRace.count.should == 3
      end
    end
  end
end
