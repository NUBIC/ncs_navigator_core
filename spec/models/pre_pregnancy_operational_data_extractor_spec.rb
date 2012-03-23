require 'spec_helper'

describe PrePregnancyOperationalDataExtractor do
  include SurveyCompletion

  before(:each) do
    create_missing_in_error_ncs_codes(Instrument)
    create_missing_in_error_ncs_codes(Person)
    create_missing_in_error_ncs_codes(Participant)
    create_missing_in_error_ncs_codes(PpgDetail)
    create_missing_in_error_ncs_codes(PpgStatusHistory)
    create_missing_in_error_ncs_codes(Telephone)
    create_missing_in_error_ncs_codes(Email)
    create_missing_in_error_ncs_codes(Address)
    create_missing_in_error_ncs_codes(DwellingUnit)
    Factory(:ncs_code, :list_name => "PERSON_PARTCPNT_RELTNSHP_CL1", :display_text => "Self", :local_code => 1)
  end

  it "extracts person operational data from the survey responses" do

    married = Factory(:ncs_code, :list_name => "MARITAL_STATUS_CL1", :display_text => "Married", :local_code => 1)

    age_eligible  = Factory(:ncs_code, :list_name => "AGE_ELIGIBLE_CL2", :display_text => "Age-Eligible", :local_code => 3)
    age_eligible2 = Factory(:ncs_code, :list_name => "AGE_ELIGIBLE_CL4", :display_text => "Age-Eligible", :local_code => 3)

    person = Factory(:person)
    participant = Factory(:participant)
    ppl = Factory(:participant_person_link, :participant_id => participant, :person_id => person, :relationship_code => 1)

    survey = create_pre_pregnancy_survey_with_person_operational_data
    response_set, instrument = prepare_instrument(person, survey)
    response_set.save!
    response_set.responses.size.should == 0

    take_survey(survey, response_set) do |a|
      a.str "#{PrePregnancyOperationalDataExtractor::INTERVIEW_PREFIX}.R_FNAME", 'Jo'
      a.str "#{PrePregnancyOperationalDataExtractor::INTERVIEW_PREFIX}.R_LNAME", 'Stafford'
      a.date "#{PrePregnancyOperationalDataExtractor::INTERVIEW_PREFIX}.PERSON_DOB", '01/01/1981'
      a.choice "#{PrePregnancyOperationalDataExtractor::INTERVIEW_PREFIX}.MARISTAT", married
    end

    response_set.responses.reload
    response_set.responses.size.should == 4

    PrePregnancyOperationalDataExtractor.extract_data(response_set)

    person = Person.find(person.id)
    person.first_name.should == "Jo"
    person.last_name.should == "Stafford"
    person.person_dob.should == "1981-01-01"
    person.age.should == Date.today.year - 1981

    person.marital_status.should == married
  end

  it "extracts cell phone operational data from the survey responses" do

    cell = Factory(:ncs_code, :list_name => "PHONE_TYPE_CL1", :display_text => "Cell", :local_code => 3)

    person = Factory(:person)
    person.telephones.size.should == 0

    survey = create_pre_pregnancy_survey_with_telephone_operational_data
    response_set, instrument = prepare_instrument(person, survey)
    response_set.save!
    response_set.responses.size.should == 0

    take_survey(survey, response_set) do |a|
      a.yes "#{PrePregnancyOperationalDataExtractor::INTERVIEW_PREFIX}.CELL_PHONE_2"
      a.yes "#{PrePregnancyOperationalDataExtractor::INTERVIEW_PREFIX}.CELL_PHONE_4"
      a.str "#{PrePregnancyOperationalDataExtractor::INTERVIEW_PREFIX}.CELL_PHONE", '3125557890'
    end

    response_set.responses.reload
    response_set.responses.size.should == 3

    PrePregnancyOperationalDataExtractor.extract_data(response_set)

    person  = Person.find(person.id)
    person.telephones.size.should == 1
    telephone = person.telephones.first

    telephone.phone_type.should == cell
    telephone.phone_nbr.should == "3125557890"

  end

  it "extracts email operational data from the survey responses" do
    person = Factory(:person)
    person.telephones.size.should == 0

    survey = create_pre_pregnancy_survey_with_email_operational_data
    response_set, instrument = prepare_instrument(person, survey)
    response_set.save!
    response_set.responses.size.should == 0

    take_survey(survey, response_set) do |a|
      a.str "#{PrePregnancyOperationalDataExtractor::INTERVIEW_PREFIX}.EMAIL", 'email@dev.null'
    end

    response_set.responses.reload
    response_set.responses.size.should == 1

    PrePregnancyOperationalDataExtractor.extract_data(response_set)

    person = Person.find(person.id)
    person.emails.size.should == 1
    person.emails.first.email.should == "email@dev.null"
  end

  context "extracting contact information from the survey responses" do

    before(:each) do
      Factory(:ncs_code, :list_name => "CONTACT_RELATIONSHIP_CL2", :display_text => "Mother/Father", :local_code => 1)
      Factory(:ncs_code, :list_name => "CONTACT_RELATIONSHIP_CL2", :display_text => "Brother/Sister", :local_code => 2)
      @contact_aunt_uncle = Factory(:ncs_code, :list_name => "CONTACT_RELATIONSHIP_CL2", :display_text => "Aunt/Uncle", :local_code => 3)
      @contact_grandparent = Factory(:ncs_code, :list_name => "CONTACT_RELATIONSHIP_CL2", :display_text => "Grandparent", :local_code => 4)
      @contact_neighbor = Factory(:ncs_code, :list_name => "CONTACT_RELATIONSHIP_CL2", :display_text => "Neighbor", :local_code => 5)
      @contact_friend = Factory(:ncs_code, :list_name => "CONTACT_RELATIONSHIP_CL2", :display_text => "Friend", :local_code => 6)
      Factory(:ncs_code, :list_name => "CONTACT_RELATIONSHIP_CL2", :display_text => "Other", :local_code => -5)

      @person = Factory(:person)
      @participant = Factory(:participant)
      @participant.person = @person
      @participant.save!
      Factory(:ppg_detail, :participant => @participant)

      # CONTACT_RELATIONSHIP_CL2

      # PERSON_PARTCPNT_RELTNSHP_CL1
      Factory(:ncs_code, :list_name => "PERSON_PARTCPNT_RELTNSHP_CL1", :display_text => "Participant/Self", :local_code => 1)
      Factory(:ncs_code, :list_name => "PERSON_PARTCPNT_RELTNSHP_CL1", :display_text => "Biological Mother", :local_code => 2)
      Factory(:ncs_code, :list_name => "PERSON_PARTCPNT_RELTNSHP_CL1", :display_text => "Non-Biological Mother", :local_code => 3)
      Factory(:ncs_code, :list_name => "PERSON_PARTCPNT_RELTNSHP_CL1", :display_text => "Biological Father", :local_code => 4)
      Factory(:ncs_code, :list_name => "PERSON_PARTCPNT_RELTNSHP_CL1", :display_text => "Non-Biological Father", :local_code => 5)
      Factory(:ncs_code, :list_name => "PERSON_PARTCPNT_RELTNSHP_CL1", :display_text => "Spouse", :local_code => 6)
      Factory(:ncs_code, :list_name => "PERSON_PARTCPNT_RELTNSHP_CL1", :display_text => "Partner/Significant Other", :local_code => 7)
      Factory(:ncs_code, :list_name => "PERSON_PARTCPNT_RELTNSHP_CL1", :display_text => "Child", :local_code => 8)
      Factory(:ncs_code, :list_name => "PERSON_PARTCPNT_RELTNSHP_CL1", :display_text => "Sibling", :local_code => 9)
      @ppr_grandparent = Factory(:ncs_code, :list_name => "PERSON_PARTCPNT_RELTNSHP_CL1", :display_text => "Grandparent", :local_code => 10)
      @ppr_other_rel = Factory(:ncs_code, :list_name => "PERSON_PARTCPNT_RELTNSHP_CL1", :display_text => "Other relative", :local_code => 11)
      @ppr_friend = Factory(:ncs_code, :list_name => "PERSON_PARTCPNT_RELTNSHP_CL1", :display_text => "Friend", :local_code => 12)
      @ppr_neighbor = Factory(:ncs_code, :list_name => "PERSON_PARTCPNT_RELTNSHP_CL1", :display_text => "Neighbor", :local_code => 13)
      Factory(:ncs_code, :list_name => "PERSON_PARTCPNT_RELTNSHP_CL1", :display_text => "Co-Worker", :local_code => 14)
      Factory(:ncs_code, :list_name => "PERSON_PARTCPNT_RELTNSHP_CL1", :display_text => "Care-giver", :local_code => 15)
      Factory(:ncs_code, :list_name => "PERSON_PARTCPNT_RELTNSHP_CL1", :display_text => "Teacher", :local_code => 16)
      Factory(:ncs_code, :list_name => "PERSON_PARTCPNT_RELTNSHP_CL1", :display_text => "Primary health care provider", :local_code => 17)
      Factory(:ncs_code, :list_name => "PERSON_PARTCPNT_RELTNSHP_CL1", :display_text => "Other health care provider", :local_code => 18)
      Factory(:ncs_code, :list_name => "PERSON_PARTCPNT_RELTNSHP_CL1", :display_text => "Other", :local_code => -5)

      @survey = create_pre_pregnancy_survey_with_contact_operational_data
      @response_set, @instrument = prepare_instrument(@person, @survey)
      @response_set.save!
      @response_set.responses.size.should == 0
      @participant.participant_person_links.size.should == 1
    end

    it "creates a new person record and associates it with the particpant" do
      state = Factory(:ncs_code, :list_name => "STATE_CL1", :display_text => "IL", :local_code => 14)

      take_survey(@survey, @response_set) do |a|
        a.str "#{PrePregnancyOperationalDataExtractor::INTERVIEW_PREFIX}.CONTACT_FNAME_1", 'Donna'
        a.str "#{PrePregnancyOperationalDataExtractor::INTERVIEW_PREFIX}.CONTACT_LNAME_1", 'Noble'
        a.choice "#{PrePregnancyOperationalDataExtractor::INTERVIEW_PREFIX}.CONTACT_RELATE_1", @contact_friend
        a.str "#{PrePregnancyOperationalDataExtractor::INTERVIEW_PREFIX}.C_ADDR_1_1", '123 Easy St.'
        a.str "#{PrePregnancyOperationalDataExtractor::INTERVIEW_PREFIX}.C_ADDR_2_1", ''
        a.str "#{PrePregnancyOperationalDataExtractor::INTERVIEW_PREFIX}.C_UNIT_1", ''
        a.str "#{PrePregnancyOperationalDataExtractor::INTERVIEW_PREFIX}.C_CITY_1", 'Chicago'
        a.choice "#{PrePregnancyOperationalDataExtractor::INTERVIEW_PREFIX}.C_STATE_1", state
        a.str "#{PrePregnancyOperationalDataExtractor::INTERVIEW_PREFIX}.C_ZIP_1", '65432'
        a.str "#{PrePregnancyOperationalDataExtractor::INTERVIEW_PREFIX}.C_ZIP4_1", '1234'
        a.str "#{PrePregnancyOperationalDataExtractor::INTERVIEW_PREFIX}.CONTACT_PHONE_1", '3125551212'
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 11

      PrePregnancyOperationalDataExtractor.extract_data(@response_set)

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
      friend.addresses.first.to_s.should == "123 Easy St. Chicago, IL 65432-1234"
    end

    it "creates another new person record and associates it with the particpant" do
      state = Factory(:ncs_code, :list_name => "STATE_CL1", :display_text => "IL", :local_code => 14)

      take_survey(@survey, @response_set) do |a|
        a.str "#{PrePregnancyOperationalDataExtractor::INTERVIEW_PREFIX}.CONTACT_FNAME_2", 'Carole'
        a.str "#{PrePregnancyOperationalDataExtractor::INTERVIEW_PREFIX}.CONTACT_LNAME_2", 'King'
        a.choice "#{PrePregnancyOperationalDataExtractor::INTERVIEW_PREFIX}.CONTACT_RELATE_2", @contact_neighbor
        a.str "#{PrePregnancyOperationalDataExtractor::INTERVIEW_PREFIX}.C_ADDR_1_2", '123 Tapestry St.'
        a.str "#{PrePregnancyOperationalDataExtractor::INTERVIEW_PREFIX}.C_ADDR_2_2", ''
        a.str "#{PrePregnancyOperationalDataExtractor::INTERVIEW_PREFIX}.C_UNIT_2", ''
        a.str "#{PrePregnancyOperationalDataExtractor::INTERVIEW_PREFIX}.C_CITY_2", 'Chicago'
        a.choice "#{PrePregnancyOperationalDataExtractor::INTERVIEW_PREFIX}.C_STATE_2", state
        a.str "#{PrePregnancyOperationalDataExtractor::INTERVIEW_PREFIX}.C_ZIP_2", '65432'
        a.str "#{PrePregnancyOperationalDataExtractor::INTERVIEW_PREFIX}.C_ZIP4_2", '1234'
        a.str "#{PrePregnancyOperationalDataExtractor::INTERVIEW_PREFIX}.CONTACT_PHONE_2", '3125551212'
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 11

      PrePregnancyOperationalDataExtractor.extract_data(@response_set)

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
      neighbor.addresses.first.to_s.should == "123 Tapestry St. Chicago, IL 65432-1234"
    end

    it "creates an other relative person record and associates it with the particpant" do
      state = Factory(:ncs_code, :list_name => "STATE_CL1", :display_text => "IL", :local_code => 14)

      take_survey(@survey, @response_set) do |a|
        a.str "#{PrePregnancyOperationalDataExtractor::INTERVIEW_PREFIX}.CONTACT_FNAME_1", 'Ivy'
        a.str "#{PrePregnancyOperationalDataExtractor::INTERVIEW_PREFIX}.CONTACT_LNAME_1", 'Anderson'
        a.choice "#{PrePregnancyOperationalDataExtractor::INTERVIEW_PREFIX}.CONTACT_RELATE_1", @contact_aunt_uncle
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 3

      PrePregnancyOperationalDataExtractor.extract_data(@response_set)

      person  = Person.find(@person.id)
      participant = person.participant
      participant.participant_person_links.size.should == 2
      participant.other_relatives.size.should == 1
      aunt = participant.other_relatives.first
      aunt.first_name.should == "Ivy"
      aunt.last_name.should == "Anderson"
    end

    it "creates a grandparent person record and associates it with the particpant" do
      state = Factory(:ncs_code, :list_name => "STATE_CL1", :display_text => "IL", :local_code => 14)

      take_survey(@survey, @response_set) do |a|
        a.str "#{PrePregnancyOperationalDataExtractor::INTERVIEW_PREFIX}.CONTACT_FNAME_1", 'Billie'
        a.str "#{PrePregnancyOperationalDataExtractor::INTERVIEW_PREFIX}.CONTACT_LNAME_1", 'Holiday'
        a.choice "#{PrePregnancyOperationalDataExtractor::INTERVIEW_PREFIX}.CONTACT_RELATE_1", @contact_grandparent
      end

      @response_set.responses.reload
      @response_set.responses.size.should == 3

      PrePregnancyOperationalDataExtractor.extract_data(@response_set)

      person  = Person.find(@person.id)
      participant = person.participant
      participant.participant_person_links.size.should == 2
      participant.grandparents.size.should == 1
      mimi = participant.grandparents.first
      mimi.first_name.should == "Billie"
      mimi.last_name.should == "Holiday"
    end

  end

end
