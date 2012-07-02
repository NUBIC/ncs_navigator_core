

require 'spec_helper'

describe BirthOperationalDataExtractor do
  include SurveyCompletion

  context "creating a new person record for the child" do
    before(:each) do
      @male   = NcsCode.for_list_name_and_local_code("GENDER_CL1", 1)
      @female = NcsCode.for_list_name_and_local_code("GENDER_CL1", 2)

      @person = Factory(:person)
      @participant = Factory(:participant)
      @participant.person = @person
      Factory(:ppg_detail, :participant => @participant)

      @participant.participant_person_links.size.should == 1
    end

    it "creates a new person (Child) record and associates it with the particpant" do
      survey = create_birth_survey_with_child_operational_data
      response_set, instrument = prepare_instrument(@person, survey)

      take_survey(survey, response_set) do |a|
        a.str "#{BirthOperationalDataExtractor::BABY_NAME_PREFIX}.BABY_FNAME", 'Mary'
        a.str "#{BirthOperationalDataExtractor::BABY_NAME_PREFIX}.BABY_MNAME", 'Jane'
        a.str "#{BirthOperationalDataExtractor::BABY_NAME_PREFIX}.BABY_LNAME", 'Williams'
        a.choice "#{BirthOperationalDataExtractor::BABY_NAME_PREFIX}.BABY_SEX", @female
      end

      response_set.responses.reload
      response_set.responses.size.should == 4

      BirthOperationalDataExtractor.extract_data(response_set)

      person  = Person.find(@person.id)
      participant = person.participant
      participant.participant_person_links.size.should == 2
      participant.children.should_not be_nil
      child = participant.children.first
      child.first_name.should == "Mary"
      child.last_name.should == "Williams"
      child.sex.should == @female

      # child.mother.should == person - will not know until child is a participant
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
      @participant = Factory(:participant)
      @participant.person = @person
      @survey = create_birth_survey_with_tracing_operational_data
    end

    it "extracts person operational data from the survey responses" do
      response_set, instrument = prepare_instrument(@person, @survey)

      take_survey(@survey, response_set) do |a|
        a.str "#{BirthOperationalDataExtractor::BIRTH_VISIT_PREFIX}.R_FNAME", 'Jocelyn'
        a.str "#{BirthOperationalDataExtractor::BIRTH_VISIT_PREFIX}.R_LNAME", 'Goldsmith'
      end

      response_set.responses.reload
      response_set.responses.size.should == 2

      BirthOperationalDataExtractor.extract_data(response_set)

      person = Person.find(@person.id)
      person.first_name.should == "Jocelyn"
      person.last_name.should == "Goldsmith"
    end

    it "extracts mailing address data" do

      state = NcsCode.for_list_name_and_local_code("STATE_CL1", 14)

      @person.addresses.size.should == 0

      response_set, instrument = prepare_instrument(@person, @survey)

      take_survey(@survey, response_set) do |a|
        a.str "#{BirthOperationalDataExtractor::BIRTH_VISIT_PREFIX}.MAIL_ADDRESS1", '123 Easy St.'
        a.str "#{BirthOperationalDataExtractor::BIRTH_VISIT_PREFIX}.MAIL_ADDRESS2", ''
        a.str "#{BirthOperationalDataExtractor::BIRTH_VISIT_PREFIX}.MAIL_UNIT", ''
        a.str "#{BirthOperationalDataExtractor::BIRTH_VISIT_PREFIX}.MAIL_CITY", 'Chicago'
        a.choice "#{BirthOperationalDataExtractor::BIRTH_VISIT_PREFIX}.MAIL_STATE", state
        a.str "#{BirthOperationalDataExtractor::BIRTH_VISIT_PREFIX}.MAIL_ZIP", '65432'
        a.str "#{BirthOperationalDataExtractor::BIRTH_VISIT_PREFIX}.MAIL_ZIP4", '1234'
      end

      response_set.responses.reload
      response_set.responses.size.should == 7

      BirthOperationalDataExtractor.extract_data(response_set)

      person  = Person.find(@person.id)
      person.addresses.size.should == 1
      address = person.addresses.first
      address.to_s.should == "123 Easy St. Chicago, ILLINOIS 65432-1234"
      address.address_rank_code.should == 1
    end

    it "extracts telephone operational data" do
      response_set, instrument = prepare_instrument(@person, @survey)
      @person.telephones.size.should == 0

      take_survey(@survey, response_set) do |a|
        a.str "#{BirthOperationalDataExtractor::BIRTH_VISIT_PREFIX}.PHONE_NBR", '3125551234'
        a.str "#{BirthOperationalDataExtractor::BIRTH_VISIT_PREFIX}.PHONE_NBR_OTH", ''
        a.choice "#{BirthOperationalDataExtractor::BIRTH_VISIT_PREFIX}.PHONE_TYPE", cell
        a.str "#{BirthOperationalDataExtractor::BIRTH_VISIT_PREFIX}.PHONE_TYPE_OTH", ''
        a.str "#{BirthOperationalDataExtractor::BIRTH_VISIT_PREFIX}.HOME_PHONE", '3125554321'
        a.yes "#{BirthOperationalDataExtractor::BIRTH_VISIT_PREFIX}.CELL_PHONE_2"
        a.yes "#{BirthOperationalDataExtractor::BIRTH_VISIT_PREFIX}.CELL_PHONE_4"
        a.str "#{BirthOperationalDataExtractor::BIRTH_VISIT_PREFIX}.CELL_PHONE", '3125557890'
      end

      response_set.responses.reload
      response_set.responses.size.should == 8

      BirthOperationalDataExtractor.extract_data(response_set)

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

      response_set, instrument = prepare_instrument(@person, @survey)

      take_survey(@survey, response_set) do |a|
        a.str "#{BirthOperationalDataExtractor::BIRTH_VISIT_PREFIX}.EMAIL", 'email@dev.null'
        a.choice "#{BirthOperationalDataExtractor::BIRTH_VISIT_PREFIX}.EMAIL_TYPE", home
      end

      response_set.responses.reload
      response_set.responses.size.should == 2

      BirthOperationalDataExtractor.extract_data(response_set)

      person  = Person.find(@person.id)
      person.emails.size.should == 2
      person.emails.first.email.should == "asdf@asdf.asdf"
      person.emails.first.email_rank_code.should == 2

      person.emails.last.email.should == "email@dev.null"
      person.emails.last.email_rank_code.should == 1

    end

  end

end
