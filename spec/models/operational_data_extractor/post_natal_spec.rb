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
      @link = Factory(:participant_person_link, :participant => @child_participant, :person => @child_person )
      @survey = create_six_month_mother_int_mother_detail_survey_with_operational_data
    end

    it "extracts the child data from survey responses, associating it with the child" do
      response_set, instrument = prepare_instrument(@person, @child_participant, @survey)
      response_set.save!

      take_survey(@survey, response_set) do |a|
        a.str "#{OperationalDataExtractor::PostNatal::SIX_MONTH_CHILD_SECTION_PREFIX}.C_FNAME", 'Jo'
        a.str "#{OperationalDataExtractor::PostNatal::SIX_MONTH_CHILD_SECTION_PREFIX}.C_LNAME", 'Stafford'
        a.date "#{OperationalDataExtractor::PostNatal::SIX_MONTH_CHILD_SECTION_PREFIX}.CHILD_DOB", '01/01/2012'
      end

      response_set.responses.reload
      response_set.responses.size.should == 3

      OperationalDataExtractor::PostNatal.extract_data(response_set)

      Person.where(:id => @child_person.id)

      Person.where(:id => @child_person.id).first.first_name.should == "Jo"
      Person.where(:id => @child_person.id).first.last_name.should == "Stafford"
      Person.where(:id => @child_person.id).first.person_dob.should == "2012-01-01"
    end

  end

  context "extracting email data " do

    before(:each) do
      @person = Factory(:person)
      @responses_set = Factory(:response_set, :person => @person)
      @participant = Factory(:participant)
      @participant.person = @person
      @survey = create_six_month_mother_int_mother_detail_survey_with_operational_data
    end

    it "extracts the email data from survey responses" do
      @response_set, instrument = prepare_instrument(@person, @participant, @survey)
      @response_set.save!

      take_survey(@survey, @response_set) do |a|
        a.str "#{OperationalDataExtractor::PostNatal::SIX_MONTH_MOTHER_SECTION_PREFIX}.EMAIL", 'email@dev.null'
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 1

      OperationalDataExtractor::PostNatal.extract_data(@response_set)

      Person.where(:response_set_id == @response_set.id).first.emails.first.email.should == "email@dev.null"
    end
  end

  context "extracting cell phone data " do

    before(:each) do
      @person = Factory(:person)
      @responses_set = Factory(:response_set, :person => @person)
      @participant = Factory(:participant)
      @participant.person = @person
      @survey = create_six_month_mother_int_mother_detail_survey_with_operational_data
    end

    it "extracts the cell phone data from survey responses" do
      @response_set, instrument = prepare_instrument(@person, @participant, @survey)
      @response_set.save!

      take_survey(@survey, @response_set) do |a|
        a.yes "#{OperationalDataExtractor::PostNatal::SIX_MONTH_MOTHER_SECTION_PREFIX}.CELL_PHONE_1"
        a.yes "#{OperationalDataExtractor::PostNatal::SIX_MONTH_MOTHER_SECTION_PREFIX}.CELL_PHONE_2"
        a.yes "#{OperationalDataExtractor::PostNatal::SIX_MONTH_MOTHER_SECTION_PREFIX}.CELL_PHONE_4"
        a.str "#{OperationalDataExtractor::PostNatal::SIX_MONTH_MOTHER_SECTION_PREFIX}.CELL_PHONE", '3125557890'
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 4

      OperationalDataExtractor::PostNatal.extract_data(@response_set)

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
      @responses_set = Factory(:response_set, :person => @person)
      @participant = Factory(:participant)
      @participant.person = @person
      @survey = create_six_month_mother_int_mother_detail_survey_with_operational_data
    end

    it "extracts the contact name data from survey responses" do
      @response_set, instrument = prepare_instrument(@person, @participant, @survey)
      @response_set.save!

      state = NcsCode.for_list_name_and_local_code("STATE_CL1", 14)

      take_survey(@survey, @response_set) do |a|
        a.str "#{OperationalDataExtractor::PostNatal::SIX_MONTH_MOTHER_SECTION_PREFIX}.CONTACT_FNAME_1", 'Donna'
        a.str "#{OperationalDataExtractor::PostNatal::SIX_MONTH_MOTHER_SECTION_PREFIX}.CONTACT_LNAME_1", 'Noble'
        a.choice "#{OperationalDataExtractor::PostNatal::SIX_MONTH_MOTHER_SECTION_PREFIX}.CONTACT_RELATE_1", @contact_neighbor
        a.str "#{OperationalDataExtractor::PostNatal::SIX_MONTH_MOTHER_SECTION_PREFIX}.C_ADDR_1_1", '123 Easy St.'
        a.str "#{OperationalDataExtractor::PostNatal::SIX_MONTH_MOTHER_SECTION_PREFIX}.C_ADDR_2_1", ''
        a.str "#{OperationalDataExtractor::PostNatal::SIX_MONTH_MOTHER_SECTION_PREFIX}.C_UNIT_1", ''
        a.str "#{OperationalDataExtractor::PostNatal::SIX_MONTH_MOTHER_SECTION_PREFIX}.C_CITY_1", 'Chicago'
        a.choice "#{OperationalDataExtractor::PostNatal::SIX_MONTH_MOTHER_SECTION_PREFIX}.C_STATE_1", state
        a.str "#{OperationalDataExtractor::PostNatal::SIX_MONTH_MOTHER_SECTION_PREFIX}.C_ZIP_1", '65432'
        a.str "#{OperationalDataExtractor::PostNatal::SIX_MONTH_MOTHER_SECTION_PREFIX}.C_ZIP4_1", '1234'
        a.str "#{OperationalDataExtractor::PostNatal::SIX_MONTH_MOTHER_SECTION_PREFIX}.CONTACT_PHONE_1", '3125551212'
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 11

      OperationalDataExtractor::PostNatal.extract_data(@response_set)

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
      neighbor.addresses.first.to_s.should == "123 Easy St. Chicago, ILLINOIS 65432-1234"
      neighbor.addresses.first.address_rank_code.should == 1
    end

  end

end
