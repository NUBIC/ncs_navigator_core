# -*- coding: utf-8 -*-

require 'spec_helper'

describe OperationalDataExtractor::PostNatal do
  include SurveyCompletion

  context "extracting child data" do

    before(:each) do
      @person = Factory(:person)
      @child_person = Factory(:person)
      @child_participant = Factory(:participant)
      @child_participant.person = @child_person
      @child_participant.save!
      @survey = create_six_month_mother_int_mother_detail_survey_with_operational_data
    end

    it "extracts the child data from survey responses, associating it with the child" do
      response_set, instrument = prepare_instrument(@person, @child_participant, @survey)
      response_set.save!

      take_survey(@survey, response_set) do |r|
        r.a "#{OperationalDataExtractor::PostNatal::SIX_MONTH_CHILD_SECTION_PREFIX}.C_FNAME", 'Jo'
        r.a "#{OperationalDataExtractor::PostNatal::SIX_MONTH_CHILD_SECTION_PREFIX}.C_LNAME", 'Stafford'
        r.a "#{OperationalDataExtractor::PostNatal::SIX_MONTH_CHILD_SECTION_PREFIX}.CHILD_DOB", '2012-01-01'
      end

      response_set.responses.reload
      response_set.responses.size.should == 3

      OperationalDataExtractor::PostNatal.new(response_set).extract_data

      person = Participant.where(:id => @child_participant.id).first.person

      person.first_name.should == "Jo"
      person.last_name.should == "Stafford"
      person.person_dob.should == "2012-01-01"
    end

  end

  context "extracting email data " do

    before(:each) do
      @person = Factory(:person)
      @participant = Factory(:participant)
      @participant.person = @person
      @survey = create_six_month_mother_int_mother_detail_survey_with_operational_data
    end

    it "extracts the email data from survey responses" do
      @response_set, instrument = prepare_instrument(@person, @participant, @survey)
      @response_set.save!

      take_survey(@survey, @response_set) do |r|
        r.a "#{OperationalDataExtractor::PostNatal::SIX_MONTH_MOTHER_SECTION_PREFIX}.EMAIL", 'email@dev.null'
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 1

      OperationalDataExtractor::PostNatal.new(@response_set).extract_data

      Person.where(:response_set_id == @response_set.id).first.emails.first.email.should == "email@dev.null"
    end
  end

  context "extracting cell phone data " do

    before(:each) do
      @person = Factory(:person)
      @participant = Factory(:participant)
      @participant.person = @person
      @survey = create_six_month_mother_int_mother_detail_survey_with_operational_data
    end

    it "extracts the cell phone data from survey responses" do
      @response_set, instrument = prepare_instrument(@person, @participant, @survey)
      @response_set.save!

      take_survey(@survey, @response_set) do |r|
        r.yes "#{OperationalDataExtractor::PostNatal::SIX_MONTH_MOTHER_SECTION_PREFIX}.CELL_PHONE_1"
        r.yes "#{OperationalDataExtractor::PostNatal::SIX_MONTH_MOTHER_SECTION_PREFIX}.CELL_PHONE_2"
        r.yes "#{OperationalDataExtractor::PostNatal::SIX_MONTH_MOTHER_SECTION_PREFIX}.CELL_PHONE_4"
        r.a "#{OperationalDataExtractor::PostNatal::SIX_MONTH_MOTHER_SECTION_PREFIX}.CELL_PHONE", '3125557890'
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 4

      OperationalDataExtractor::PostNatal.new(@response_set).extract_data

      Person.where(:response_set_id == @response_set.id).first.telephones.first.phone_nbr.should == '3125557890'
    end

  end

  context "extracting contact data" do

    before(:each) do
      @contact_neighbor = NcsCode.for_list_name_and_local_code("CONTACT_RELATIONSHIP_CL2", 5)
      @contact_grandparent = NcsCode.for_list_name_and_local_code("CONTACT_RELATIONSHIP_CL2", 4)
      @ppr_neighbor = NcsCode.for_list_name_and_local_code("PERSON_PARTCPNT_RELTNSHP_CL1", 13)
      @ppr_grandparent = NcsCode.for_list_name_and_local_code("PERSON_PARTCPNT_RELTNSHP_CL1", 10)

      @person = Factory(:person)
      @participant = Factory(:participant)
      @participant.person = @person
      @participant.save!
      @survey = create_six_month_mother_int_mother_detail_survey_with_operational_data
    end

    it "extracts the contact name data from survey responses" do
      @response_set, instrument = prepare_instrument(@person, @participant, @survey)
      @response_set.save!

      state = NcsCode.for_list_name_and_local_code("STATE_CL1", 14)

      take_survey(@survey, @response_set) do |r|
        r.a "#{OperationalDataExtractor::PostNatal::SIX_MONTH_MOTHER_SECTION_PREFIX}.CONTACT_FNAME_1", 'Donna'
        r.a "#{OperationalDataExtractor::PostNatal::SIX_MONTH_MOTHER_SECTION_PREFIX}.CONTACT_LNAME_1", 'Noble'
        r.a "#{OperationalDataExtractor::PostNatal::SIX_MONTH_MOTHER_SECTION_PREFIX}.CONTACT_RELATE_1", @contact_neighbor
        r.a "#{OperationalDataExtractor::PostNatal::SIX_MONTH_MOTHER_SECTION_PREFIX}.C_ADDR_1_1", '123 Easy St.'
        r.a "#{OperationalDataExtractor::PostNatal::SIX_MONTH_MOTHER_SECTION_PREFIX}.C_ADDR_2_1", ''
        r.a "#{OperationalDataExtractor::PostNatal::SIX_MONTH_MOTHER_SECTION_PREFIX}.C_UNIT_1", ''
        r.a "#{OperationalDataExtractor::PostNatal::SIX_MONTH_MOTHER_SECTION_PREFIX}.C_CITY_1", 'Chicago'
        r.a "#{OperationalDataExtractor::PostNatal::SIX_MONTH_MOTHER_SECTION_PREFIX}.C_STATE_1", state
        r.a "#{OperationalDataExtractor::PostNatal::SIX_MONTH_MOTHER_SECTION_PREFIX}.C_ZIP_1", '65432'
        r.a "#{OperationalDataExtractor::PostNatal::SIX_MONTH_MOTHER_SECTION_PREFIX}.C_ZIP4_1", '1234'
        r.a "#{OperationalDataExtractor::PostNatal::SIX_MONTH_MOTHER_SECTION_PREFIX}.CONTACT_PHONE_1", '3125551212'
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 11

      OperationalDataExtractor::PostNatal.new(@response_set).extract_data

      person  = Person.find(@person.id)
      participant = person.participant
      participant.participant_person_links.size.should == 2
      participant.neighbors.size.should == 1
      neighbor = participant.neighbors.first
      neighbor.first_name.should == "Donna"
      neighbor.last_name.should == "Noble"
      neighbor.telephones.first.should_not be_nil
      neighbor.telephones.first.phone_nbr.should == "3125551212"

      neighbor.addresses.first.should_not be_nil
      neighbor.addresses.first.to_s.should == "123 Easy St. Chicago, Illinois 65432-1234"
      neighbor.addresses.first.address_rank_code.should == 1
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
      @survey = create_three_month_mother_int_part_two_survey_with_person_race_operational_data
      @response_set, instrument = prepare_instrument(@person, participant, @survey)
    end

    describe "processing racial data" do
      before do
        take_survey(@survey, @response_set) do |r|
          r.a "#{OperationalDataExtractor::PostNatal::THREE_MONTH_MOTHER_RACE_PREFIX}.RACE", black_race
          r.a "#{OperationalDataExtractor::PostNatal::THREE_MONTH_MOTHER_RACE_PREFIX}.RACE", other_race
          r.a "#{OperationalDataExtractor::PostNatal::THREE_MONTH_MOTHER_RACE_PREFIX}.RACE_OTH", "Aborigine"
        end

        OperationalDataExtractor::PostNatal.new(@response_set).extract_data
      end

      it "extracts three standard racial data" do
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

  end

end
