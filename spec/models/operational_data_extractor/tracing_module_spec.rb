# -*- coding: utf-8 -*-


require 'spec_helper'

describe OperationalDataExtractor::TracingModule do
  include SurveyCompletion

  context "when the participant is nil" do

    it "processes the person information" do
      person = Factory(:person)
      person.addresses.size.should == 0

      survey = create_tracing_module_survey_with_address_operational_data
      response_set, instrument = prepare_instrument(person, nil, survey)
      response_set.save!

      take_survey(survey, response_set) do |r|
        r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.ADDRESS_1", '123 Easy St.'
        r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.CITY", 'Chicago'
        r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.ZIP", '65432'
        r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.ZIP4", '1234'
      end

      response_set.responses.reload
      response_set.responses.size.should == 4

      OperationalDataExtractor::TracingModule.new(response_set).extract_data

      person = Person.find(person.id)
      person.addresses.size.should == 1
      address = person.addresses.first
      address.to_s.should == "123 Easy St. Chicago 65432-1234"
    end

    it "does not process participant contact information" do
      person = Factory(:person)

      survey = create_tracing_module_survey_with_contact_operational_data
      response_set, instrument = prepare_instrument(person, nil, survey)
      response_set.save!

      take_survey(survey, response_set) do |r|
        r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.CONTACT_FNAME_1", 'Will'
        r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.CONTACT_LNAME_1", 'Notbesaved'
      end

      response_set.responses.reload
      response_set.responses.size.should == 2

      OperationalDataExtractor::TracingModule.new(response_set).extract_data

      person  = Person.find(person.id)
      person.participant.should be_nil

      Person.where(:first_name => "Will", :last_name => "Notbesaved").all.should be_blank
    end

  end

  it "extracts address operational data from the survey responses" do
    state = NcsCode.for_list_name_and_local_code("STATE_CL1", 14)

    person = Factory(:person)
    person.addresses.size.should == 0

    participant = Factory(:participant)
    participant.person = person
    participant.save!
    survey = create_tracing_module_survey_with_address_operational_data
    response_set, instrument = prepare_instrument(person, participant, survey)
    response_set.save!

    take_survey(survey, response_set) do |r|
      r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.ADDRESS_1", '123 Easy St.'
      r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.ADDRESS_2", ''
      r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.UNIT", ''
      r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.CITY", 'Chicago'
      r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.STATE", state
      r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.ZIP", '65432'
      r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.ZIP4", '1234'
    end

    response_set.responses.reload
    response_set.responses.size.should == 7

    OperationalDataExtractor::TracingModule.new(response_set).extract_data

    person = Person.find(person.id)
    person.addresses.size.should == 1
    address = person.addresses.first
    address.to_s.should == "123 Easy St. Chicago, Illinois 65432-1234"
    address.address_rank_code.should == 1
  end

  it "extracts new address operational data from the survey responses" do

    state = NcsCode.for_list_name_and_local_code("STATE_CL1", 14)
    home = NcsCode.for_list_name_and_local_code("ADDRESS_CATEGORY_CL1", 1)

    person = Factory(:person)
    person.addresses.size.should == 0

    participant = Factory(:participant)
    participant.person = person
    participant.save!
    survey = create_tracing_module_survey_with_new_address_operational_data
    response_set, instrument = prepare_instrument(person, participant, survey)
    response_set.save!

    take_survey(survey, response_set) do |r|
      r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.NEW_ADDRESS1", '345 Easy St.'
      r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.NEW_ADDRESS2", ''
      r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.NEW_UNIT", ''
      r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.NEW_CITY", 'Chicago'
      r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.NEW_STATE", state
      r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.NEW_ZIP", '60666'
      r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.NEW_ZIP4", '1234'
    end

    response_set.responses.reload
    response_set.responses.size.should == 7

    OperationalDataExtractor::TracingModule.new(response_set).extract_data

    person  = Person.find(person.id)
    person.addresses.size.should == 1
    address = person.addresses.first
    address.to_s.should == "345 Easy St. Chicago, Illinois 60666-1234"
    address.address_type.should == home
    address.address_rank_code.should == 1
  end

  context "extracting telephone operational data from the survey responses" do

    let(:home) { NcsCode.for_list_name_and_local_code("PHONE_TYPE_CL1", 1) }
    let(:cell) { NcsCode.for_list_name_and_local_code("PHONE_TYPE_CL1", 3) }

    before(:each) do
      @person = Factory(:person)
      @person.telephones.size.should == 0

      @participant = Factory(:participant)
      @participant.person = @person
      @participant.save!
      @survey = create_tracing_module_survey_with_telephone_operational_data
    end

    it "extracts telephone operational data" do
      response_set, instrument = prepare_instrument(@person, @participant, @survey)
      response_set.save!

      take_survey(@survey, response_set) do |r|
        r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.HOME_PHONE", '3125554321'
        r.yes "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.CELL_PHONE_2"
        r.yes "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.CELL_PHONE_4"
        r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.CELL_PHONE", '3125557890'
      end

      response_set.responses.reload
      response_set.responses.size.should == 4

      OperationalDataExtractor::TracingModule.new(response_set).extract_data

      person  = Person.find(@person.id)
      person.telephones.size.should == 2
      person.telephones.each do |t|
        t.phone_type.should_not be_nil
        t.phone_nbr[0,6].should == "312555"
        t.phone_rank_code.should == 1
      end
      person.primary_home_phone.phone_nbr.should == '3125554321'
      person.primary_cell_phone.phone_nbr.should == '3125557890'
    end

    it "can handle non-nil and non-string answers" do
      response_set, instrument = prepare_instrument(@person, @participant, @survey)
      response_set.save!

      neg_7 = mock(NcsCode, :local_code => 'neg_7')
      take_survey(@survey, response_set) do |r|
        r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.HOME_PHONE", neg_7
        r.yes "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.CELL_PHONE_2"
        r.yes "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.CELL_PHONE_4"
        r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.CELL_PHONE", '3125557890'
      end

      response_set.responses.reload
      response_set.responses.size.should == 4

      OperationalDataExtractor::TracingModule.new(response_set).extract_data

      person  = Person.find(@person.id)
      person.telephones.size.should == 1
      person.telephones.each do |t|
        t.phone_type.should_not be_nil
        t.phone_nbr[0,6].should == "312555"
        t.phone_rank_code.should == 1
      end
      person.primary_home_phone.should be_nil
      person.primary_cell_phone.phone_nbr.should == '3125557890'
    end


  end

  it "extracts email information from the survey responses" do
    person = Factory(:person)
    person.emails.size.should == 0

    participant = Factory(:participant)
    participant.person = person
    participant.save!
    survey = create_tracing_module_survey_with_email_operational_data
    response_set, instrument = prepare_instrument(person, participant, survey)
    response_set.save!

    take_survey(survey, response_set) do |r|
      r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.EMAIL", 'email@dev.null'
    end

    response_set.responses.reload
    response_set.responses.size.should == 1

    OperationalDataExtractor::TracingModule.new(response_set).extract_data

    person  = Person.find(person.id)
    person.emails.size.should == 1
    person.emails.first.email.should == "email@dev.null"
    person.emails.first.email_rank_code.should == 1
  end

  it "can handle non-nil and non-string answers for email responses" do
    person = Factory(:person)
    person.emails.size.should == 0

    participant = Factory(:participant)
    participant.person = person
    participant.save!
    survey = create_tracing_module_survey_with_email_operational_data
    response_set, instrument = prepare_instrument(person, participant, survey)
    response_set.save!

    neg_7 = mock(NcsCode, :local_code => 'neg_7')
    take_survey(survey, response_set) do |r|
      r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.EMAIL", neg_7
    end

    response_set.responses.reload
    response_set.responses.size.should == 1

    OperationalDataExtractor::TracingModule.new(response_set).extract_data

    person  = Person.find(person.id)
    person.emails.should be_empty
  end

  context "extracting contact information from the survey responses" do

    let(:home)  { NcsCode.for_list_name_and_local_code("PHONE_TYPE_CL1", 1) }
    let(:cell)  { NcsCode.for_list_name_and_local_code("PHONE_TYPE_CL1", 3) }
    let(:state) { NcsCode.for_list_name_and_local_code("STATE_CL1", 14) }

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

      @survey = create_tracing_module_survey_with_contact_operational_data
      @response_set, @instrument = prepare_instrument(@person, @participant, @survey)
      @response_set.save!
      @participant.participant_person_links.size.should == 1
    end

    it "creates a new person record and associates it with the particpant" do

      take_survey(@survey, @response_set) do |r|
        r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.CONTACT_FNAME_1", 'Donna'
        r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.CONTACT_LNAME_1", 'Noble'
        r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.CONTACT_RELATE_1", @contact_friend
        r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.C_ADDR1_1", '123 Easy St.'
        r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.C_ADDR2_1", ''
        r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.C_UNIT_1", ''
        r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.C_CITY_1", 'Chicago'
        r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.C_STATE_1", state
        r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.C_ZIPCODE_1", '65432'
        r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.C_ZIP4_1", '1234'
        r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.CONTACT_PHONE_1", '3125551212'
        r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.CONTACT_PHONE1_TYPE_1", home
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 12

      OperationalDataExtractor::TracingModule.new(@response_set).extract_data

      person  = Person.find(@person.id)
      participant = person.participant
      participant.participant_person_links.size.should == 2
      participant.friends.size.should == 1
      friend = participant.friends.first
      friend.first_name.should == "Donna"
      friend.last_name.should == "Noble"
      friend.telephones.first.should_not be_nil
      friend.telephones.first.phone_nbr.should == "3125551212"
      friend.telephones.first.phone_type.should == home

      friend.addresses.first.should_not be_nil
      friend.addresses.first.to_s.should == "123 Easy St. Chicago, Illinois 65432-1234"
    end

    it "creates another new person record and associates it with the particpant" do

      take_survey(@survey, @response_set) do |r|
        r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.CONTACT_FNAME_2", 'Carole'
        r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.CONTACT_LNAME_2", 'King'
        r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.CONTACT_RELATE_2", @contact_neighbor
        r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.C_ADDR1_2", '123 Tapestry St.'
        r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.C_ADDR_2_2", ''
        r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.C_UNIT_2", ''
        r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.C_CITY_2", 'Chicago'
        r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.C_STATE_2", state
        r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.C_ZIPCODE_2", '65432'
        r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.C_ZIP4_2", '1234'
        r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.CONTACT_PHONE_2", '3125551212'
        r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.CONTACT_PHONE1_TYPE_2", home
        r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.CONTACT_PHONE_2_2", '3125556789'
        r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.CONTACT_PHONE2_TYPE_2", cell
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 14

      OperationalDataExtractor::TracingModule.new(@response_set).extract_data

      person  = Person.find(@person.id)
      participant = person.participant
      participant.participant_person_links.size.should == 2
      participant.neighbors.size.should == 1
      neighbor = participant.neighbors.first
      neighbor.first_name.should == "Carole"
      neighbor.last_name.should == "King"
      neighbor.telephones.size.should == 2
      neighbor.primary_home_phone.phone_nbr.should == "3125551212"
      neighbor.primary_cell_phone.phone_nbr.should == "3125556789"

      neighbor.addresses.first.should_not be_nil
      neighbor.addresses.first.to_s.should == "123 Tapestry St. Chicago, Illinois 65432-1234"
    end

    it "creates a third person record and associates it with the particpant" do

      take_survey(@survey, @response_set) do |r|
        r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.CONTACT_FNAME_2", 'Jaka'
        r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.CONTACT_LNAME_2", 'Cerebus'
        r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.CONTACT_RELATE_2", @contact_aunt_uncle
        r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.C_ADDR1_2", '123 Regency St.'
        r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.C_ADDR_2_2", ''
        r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.C_UNIT_2", ''
        r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.C_CITY_2", 'Chicago'
        r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.C_STATE_2", state
        r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.C_ZIPCODE_2", '65432'
        r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.C_ZIP4_2", '1234'
        r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.CONTACT_PHONE_2", '3125551212'
        r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.CONTACT_PHONE1_TYPE_2", home
        r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.CONTACT_PHONE_2_2", '3125556789'
        r.a "#{OperationalDataExtractor::TracingModule::TRACING_MODULE_PREFIX}.CONTACT_PHONE2_TYPE_2", cell
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 14

      OperationalDataExtractor::TracingModule.new(@response_set).extract_data

      person  = Person.find(@person.id)
      participant = person.participant
      participant.participant_person_links.size.should == 2
      participant.other_relatives.size.should == 1
      aunt = participant.other_relatives.first
      aunt.first_name.should == "Jaka"
      aunt.last_name.should == "Cerebus"
      aunt.primary_home_phone.phone_nbr.should == "3125551212"
      aunt.primary_cell_phone.phone_nbr.should == "3125556789"

      aunt.addresses.first.should_not be_nil
      aunt.addresses.first.to_s.should == "123 Regency St. Chicago, Illinois 65432-1234"
    end

  end

  context "setting instrument administration mode" do

    let(:person) { Factory(:person) }
    let(:survey) { create_tracing_survey_with_prepopulated_fields }

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
      OperationalDataExtractor::TracingModule.new(@response_set).extract_data
      Instrument.find(@instrument.id).instrument_mode_code.should == Instrument.capi
    end

    it "sets the mode to CATI" do
      take_survey(survey, @response_set) do |r|
        r.a "prepopulated_mode_of_contact", mock(NcsCode, :local_code => "cati")
      end
      OperationalDataExtractor::TracingModule.new(@response_set).extract_data
      Instrument.find(@instrument.id).instrument_mode_code.should == Instrument.cati
    end

    it "sets the mode to PAPI" do
      take_survey(survey, @response_set) do |r|
        r.a "prepopulated_mode_of_contact", mock(NcsCode, :local_code => "papi")
      end
      OperationalDataExtractor::TracingModule.new(@response_set).extract_data
      Instrument.find(@instrument.id).instrument_mode_code.should == Instrument.papi
    end

  end
end
