# -*- coding: utf-8 -*-


require 'spec_helper'

describe OperationalDataExtractor::Birth do
  include SurveyCompletion

  context "where the child is the response_set participant" do
    before(:each) do
      @male   = NcsCode.for_list_name_and_local_code("GENDER_CL1", 1)
      @female = NcsCode.for_list_name_and_local_code("GENDER_CL1", 2)
      @child_type = NcsCode.for_list_name_and_local_code("PARTICIPANT_TYPE_CL1", 6)

      @person = Factory(:person)
      @person.household_units << Factory(:household_unit)
      @participant = Factory(:participant)
      @participant.person = @person
      Factory(:ppg_detail, :participant => @participant)

      @child_participant = @participant.create_child_person_and_participant!(
        {:first_name => "child_fname", :last_name => "child_lname"})

      @participant.participant_person_links.size.should == 1
      @participant.save!
    end

    it "updates the person (Child) record" do
      survey = create_birth_survey_with_child_operational_data
      response_set, instrument = prepare_instrument(@person, @child_participant, survey)

      take_survey(survey, response_set) do |r|
        r.a "#{OperationalDataExtractor::Birth::BABY_NAME_PREFIX}.BABY_FNAME", 'Mary'
        r.a "#{OperationalDataExtractor::Birth::BABY_NAME_PREFIX}.BABY_MNAME", 'Jane'
        r.a "#{OperationalDataExtractor::Birth::BABY_NAME_PREFIX}.BABY_LNAME", 'Williams'
        r.a "#{OperationalDataExtractor::Birth::BABY_NAME_PREFIX}.BABY_SEX", @female
      end

      response_set.responses.reload
      response_set.responses.size.should == 4

      OperationalDataExtractor::Birth.new(response_set).extract_data

      mother = Person.find(@person.id)
      participant = mother.participant
      participant.participant_person_links.size.should == 2
      participant.children.should_not be_nil

      child = participant.children.first
      child.should == @child_participant.person

      child.first_name.should == "Mary"
      child.last_name.should == "Williams"
      child.sex.should == @female

      child.participant.should_not be_nil
      child.participant.should == @child_participant
      child.participant.mother.should == mother
      child.participant.mother.participant.should == participant
      child.participant.p_type.should == @child_type
      participant.children.should include(child)
    end

  end

  context "extracting tracing operational data" do

    let(:home) { NcsCode.for_list_name_and_local_code("PHONE_TYPE_CL1", 1) }
    let(:work) { NcsCode.for_list_name_and_local_code("PHONE_TYPE_CL1", 2) }
    let(:cell) { NcsCode.for_list_name_and_local_code("PHONE_TYPE_CL1", 3) }
    let(:frre) { NcsCode.for_list_name_and_local_code("PHONE_TYPE_CL1", 4) }
    let(:fax)  { NcsCode.for_list_name_and_local_code("PHONE_TYPE_CL1", 5) }
    let(:oth)  { NcsCode.for_list_name_and_local_code("PHONE_TYPE_CL1", -5) }

    before(:each) do
      @person = Factory(:person)
      @person.household_units << Factory(:household_unit)
      @participant = Factory(:participant)
      @participant.person = @person
      @participant.save!
      @survey = create_birth_survey_with_tracing_operational_data
    end

    it "extracts person operational data from the survey responses" do
      response_set, instrument = prepare_instrument(@person, @participant, @survey)

      take_survey(@survey, response_set) do |r|
        r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_PREFIX}.R_FNAME", 'Jocelyn'
        r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_PREFIX}.R_LNAME", 'Goldsmith'
      end

      response_set.responses.reload
      response_set.responses.size.should == 2

      OperationalDataExtractor::Birth.new(response_set).extract_data

      person = Person.find(@participant.person.id)
      person.first_name.should == "Jocelyn"
      person.last_name.should == "Goldsmith"
    end

    context "addresses" do
      let(:state) { NcsCode.for_list_name_and_local_code("STATE_CL1", 14) }

      it "extracts mailing address data" do

        @person.addresses.size.should == 0

        response_set, instrument = prepare_instrument(@person, @participant, @survey)

        take_survey(@survey, response_set) do |r|
          r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_PREFIX}.MAIL_ADDRESS1", '123 Easy St.'
          r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_PREFIX}.MAIL_ADDRESS2", ''
          r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_PREFIX}.MAIL_UNIT", ''
          r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_PREFIX}.MAIL_CITY", 'Chicago'
          r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_PREFIX}.MAIL_STATE", state
          r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_PREFIX}.MAIL_ZIP", '65432'
          r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_PREFIX}.MAIL_ZIP4", '1234'
        end

        response_set.responses.reload
        response_set.responses.size.should == 7

        OperationalDataExtractor::Birth.new(response_set).extract_data

        person  = Person.find(@person.id)
        person.addresses.size.should == 1
        address = person.addresses.first
        address.to_s.should == "123 Easy St. Chicago, Illinois 65432-1234"
        address.address_rank_code.should == 1
      end

      it "extracts work address data" do

        @person.addresses.size.should == 0

        response_set, instrument = prepare_instrument(@person, @participant, @survey)

        take_survey(@survey, response_set) do |r|
          r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_3_PREFIX}.WORK_ADDRESS1", '123 Easy St.'
          r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_3_PREFIX}.WORK_ADDRESS2", ''
          r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_3_PREFIX}.WORK_UNIT", ''
          r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_3_PREFIX}.WORK_CITY", 'Chicago'
          r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_3_PREFIX}.WORK_STATE", state
          r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_3_PREFIX}.WORK_ZIP", '65432'
          r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_3_PREFIX}.WORK_ZIP4", '1234'
        end

        response_set.responses.reload
        response_set.responses.size.should == 7

        OperationalDataExtractor::Birth.new(response_set).extract_data

        person  = Person.find(@person.id)
        person.addresses.size.should == 1
        address = person.addresses.first
        address.to_s.should == "123 Easy St. Chicago, Illinois 65432-1234"
        address.address_rank_code.should == 1
      end

      it "should create as many addresses as needed" do

        @person.addresses.size.should == 0

        response_set, instrument = prepare_instrument(@person, @participant, @survey)

        take_survey(@survey, response_set) do |r|
          r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_PREFIX}.MAIL_ADDRESS1", '123 Easy St.'
          r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_PREFIX}.MAIL_ADDRESS2", ''
          r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_PREFIX}.MAIL_UNIT", ''
          r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_PREFIX}.MAIL_CITY", 'Chicago'
          r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_PREFIX}.MAIL_STATE", state
          r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_PREFIX}.MAIL_ZIP", '65432'
          r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_PREFIX}.MAIL_ZIP4", '1234'

          r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_3_PREFIX}.WORK_ADDRESS1", '312 Hard St.'
          r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_3_PREFIX}.WORK_ADDRESS2", ''
          r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_3_PREFIX}.WORK_UNIT", ''
          r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_3_PREFIX}.WORK_CITY", 'Chicago'
          r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_3_PREFIX}.WORK_STATE", state
          r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_3_PREFIX}.WORK_ZIP", '65432'
          r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_3_PREFIX}.WORK_ZIP4", '1234'
        end

        response_set.responses.reload
        response_set.responses.size.should == 14

        OperationalDataExtractor::Birth.new(response_set).extract_data

        person  = Person.find(@person.id)
        person.addresses.size.should == 2

        person.primary_mailing_address.to_s.should == "123 Easy St. Chicago, Illinois 65432-1234"
        person.primary_work_address.to_s.should == "312 Hard St. Chicago, Illinois 65432-1234"
      end

    end

    it "extracts telephone operational data" do
      response_set, instrument = prepare_instrument(@person, @participant, @survey)
      @person.telephones.size.should == 0

      take_survey(@survey, response_set) do |r|
        r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_PREFIX}.PHONE_NBR", '3125551234'
        r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_PREFIX}.PHONE_NBR_OTH", ''
        r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_PREFIX}.PHONE_TYPE", cell
        r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_PREFIX}.PHONE_TYPE_OTH", ''
        r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_PREFIX}.HOME_PHONE", '3125554321'
        r.yes "#{OperationalDataExtractor::Birth::BIRTH_VISIT_PREFIX}.CELL_PHONE_2"
        r.yes "#{OperationalDataExtractor::Birth::BIRTH_VISIT_PREFIX}.CELL_PHONE_4"
        r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_PREFIX}.CELL_PHONE", '3125557890'
      end

      response_set.responses.reload
      response_set.responses.size.should == 8

      OperationalDataExtractor::Birth.new(response_set).extract_data

      person  = Person.find(@person.id)
      person.telephones.size.should == 3
      person.telephones.each do |t|
        t.phone_type.should_not be_nil
        t.phone_nbr[0,6].should == "312555"
        t.phone_rank_code.should == 1
      end
    end

    it "extracts email information from the survey responses" do

      home = NcsCode.for_list_name_and_local_code("EMAIL_TYPE_CL1", 1)
      work = NcsCode.for_list_name_and_local_code("EMAIL_TYPE_CL1", 2)

      email = Factory(:email, :email => "asdf@asdf.asdf", :person => @person)

      response_set, instrument = prepare_instrument(@person, @participant, @survey)

      take_survey(@survey, response_set) do |r|
        r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_PREFIX}.EMAIL", 'email@dev.null'
        r.a"#{OperationalDataExtractor::Birth::BIRTH_VISIT_PREFIX}.EMAIL_TYPE", home
      end

      response_set.responses.reload
      response_set.responses.size.should == 2

      OperationalDataExtractor::Birth.new(response_set).extract_data

      person  = Person.find(@person.id)
      person.emails.size.should == 2
      person.emails.first.email.should == "asdf@asdf.asdf"
      person.emails.first.email_rank_code.should == 2

      person.emails.last.email.should == "email@dev.null"
      person.emails.last.email_rank_code.should == 1
    end

    it "does not extract institution information from the survey responses" do
      # The birth instrument collects institute type and no other institution
      # details (e.g. name or address). Currently, there is no reason to create
      # an institution record with only institute type.

      hospital = NcsCode.for_list_name_and_local_code("BIRTH_PLACE_PLAN_CL1", 1)

      response_set, instrument = prepare_instrument(@person, @participant, @survey)

      take_survey(@survey, response_set) do |r|
        r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_3_PREFIX}.BIRTH_DELIVER", hospital
      end

      response_set.save!
      response_set.responses.size.should == 1

      OperationalDataExtractor::Birth.new(response_set).extract_data

      @participant.person.institutions.should be_empty
    end

  end

  context "setting instrument administration mode" do

    let(:person) { Factory(:person) }
    let(:survey) { create_birth_survey_with_prepopulated_mode_of_contact }

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
      OperationalDataExtractor::Birth.new(@response_set).extract_data
      Instrument.find(@instrument.id).instrument_mode_code.should == Instrument.capi
    end

    it "sets the mode to CATI" do
      take_survey(survey, @response_set) do |r|
        r.a "prepopulated_mode_of_contact", :reference_identifier => "cati"
      end
      OperationalDataExtractor::Birth.new(@response_set).extract_data
      Instrument.find(@instrument.id).instrument_mode_code.should == Instrument.cati
    end

    it "sets the mode to PAPI" do
      take_survey(survey, @response_set) do |r|
        r.a "prepopulated_mode_of_contact", :reference_identifier => 'papi'
      end
      OperationalDataExtractor::Birth.new(@response_set).extract_data
      Instrument.find(@instrument.id).instrument_mode_code.should == Instrument.papi
    end
  end

  context "extracting race operational data" do

    let(:white_race) { NcsCode.for_list_name_and_local_code("RACE_CL1", 1) }
    let(:black_race) { NcsCode.for_list_name_and_local_code("RACE_CL1", 2) }
    let(:other_race) { NcsCode.for_list_name_and_local_code("RACE_CL1", -5) }
    let(:vietnamese_race) { NcsCode.for_list_name_and_local_code("RACE_CL6", 9) }

    before do
      @person = Factory(:person)
      participant = Factory(:participant)
      Factory(:participant_person_link, :participant => participant, :person => @person)
      @survey = create_birth_survey_with_person_race_operational_data
      @response_set, instrument = prepare_instrument(@person, participant, @survey)
    end

    describe "processing standard racial data" do
      before do
        take_survey(@survey, @response_set) do |r|
          r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_BABY_RACE_1_3_PREFIX}.BABY_RACE_1", black_race
          r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_BABY_RACE_1_3_PREFIX}.BABY_RACE_1", other_race
          r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_BABY_RACE_1_3_PREFIX}.BABY_RACE_1_OTH", 'Aborigine'
        end

        OperationalDataExtractor::Birth.new(@response_set).extract_data
      end

      it "extracts two standard racial data" do
        @person.races.should have(2).races
      end

      it "creates at least one race record with an non-other code" do
        @person.races.map(&:race_code).should include(2)
      end

      it "creates at least one race record with an other code" do
        @person.races.map(&:race_code).should include(-5)
      end

      it "creates an other code with the text 'Aborigine'" do
        @person.races.map(&:race_other).should include("Aborigine")
      end
    end

    describe "processing new type racial data" do
      before do
        take_survey(@survey, @response_set) do |r|
          r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_BABY_RACE_NEW_3_PREFIX}.BABY_RACE_NEW", white_race
          r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_BABY_RACE_NEW_3_PREFIX}.BABY_RACE_NEW", vietnamese_race
        end

        OperationalDataExtractor::Birth.new(@response_set).extract_data
      end

      it "extracts two new type racial data" do
        @person.races.should have(2).races
      end

      it "the record with a choice that is on the standard race code list is represented as a simple code" do
        @person.races.map(&:race_code).should include(white_race.local_code)
      end

      it "the record generated from a response that is NOT on the standard race code list is represented with a code for 'other' (-5)" do
        @person.races.map(&:race_code).should include(other_race.local_code)
      end

      it "the record generated from a response that is NOT on the standard race code list should have the text associated with the choice in the 'race_other' attribute" do
        other_race_record = @person.races.detect { |race| race.race_code == other_race.local_code }
        other_race_record.race_other.should == "Vietnamese"
      end
    end
  end
end
