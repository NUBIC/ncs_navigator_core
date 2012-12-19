# -*- coding: utf-8 -*-


require 'spec_helper'

describe OperationalDataExtractor::Base do
  include SurveyCompletion

  it "sets up the test properly" do

    person = Factory(:person)
    survey = create_pregnancy_screener_survey_with_person_operational_data

    survey.sections.size.should == 1
    survey.sections.first.questions.size.should == 9

    survey.sections.first.questions.each do |q|
      case q.reference_identifier
      when "R_FNAME", "R_LNAME", "AGE", "PERSON_DOB"
        q.answers.size.should == 3
      when "AGE_RANGE"
        q.answers.size.should == 9
      when "ETHNICITY"
        q.answers.size.should == 2
      when "PERSON_LANG"
        q.answers.size.should == 3
      when "PERSON_LANG_OTH"
        q.answers.size.should == 1
      end
    end

  end

  describe "determining the proper data extractor to use" do
    let(:person) { Factory(:person) }
    let(:participant) { Factory(:participant) }

    context "with a pregnancy screener instrument" do
      it "chooses the OperationalDataExtractor::PregnancyScreener" do
        survey = create_pregnancy_screener_survey_with_ppg_detail_operational_data
        response_set, instrument = prepare_instrument(person, participant, survey)
        handler = OperationalDataExtractor::Base.extractor_for(response_set)
        handler.class.should == OperationalDataExtractor::PregnancyScreener
      end
    end

    context "with a pregnancy probability instrument" do
      it "chooses the OperationalDataExtractor::PpgFollowUp" do
        survey = create_follow_up_survey_with_ppg_status_history_operational_data
        response_set, instrument = prepare_instrument(person, participant, survey)
        handler = OperationalDataExtractor::Base.extractor_for(response_set)
        handler.class.should == OperationalDataExtractor::PpgFollowUp
      end
    end

    context "with a pre pregnancy instrument" do
      it "chooses the OperationalDataExtractor::PrePregnancy" do
        survey = create_pre_pregnancy_survey_with_person_operational_data
        response_set, instrument = prepare_instrument(person, participant, survey)
        handler = OperationalDataExtractor::Base.extractor_for(response_set)
        handler.class.should == OperationalDataExtractor::PrePregnancy
      end
    end

    context "with a pregnancy visit instrument" do
      it "chooses the OperationalDataExtractor::PregnancyVisit" do
        survey = create_pregnancy_visit_1_survey_with_person_operational_data
        response_set, instrument = prepare_instrument(person, participant, survey)
        handler = OperationalDataExtractor::Base.extractor_for(response_set)
        handler.class.should == OperationalDataExtractor::PregnancyVisit
      end
    end

    context "with a birth visit instrument" do
      it "chooses the OperationalDataExtractor::Birth" do
        survey = create_birth_survey_with_child_operational_data
        response_set, instrument = prepare_instrument(person, participant, survey)
        handler = OperationalDataExtractor::Base.extractor_for(response_set)
        handler.class.should == OperationalDataExtractor::Birth
      end
    end

    context "with a lo i pregnancy screener instrument" do
      it "chooses the OperationalDataExtractor::LowIntensityPregnancyVisit" do
        survey = create_li_pregnancy_screener_survey_with_ppg_status_history_operational_data
        response_set, instrument = prepare_instrument(person, participant, survey)
        handler = OperationalDataExtractor::Base.extractor_for(response_set)
        handler.class.should == OperationalDataExtractor::LowIntensityPregnancyVisit
      end
    end

    context "with an adult blood instrument" do
      it "chooses the OperationalDataExtractor::Specimen" do
        survey = create_adult_blood_survey_with_specimen_operational_data
        response_set, instrument = prepare_instrument(person, participant, survey)
        handler = OperationalDataExtractor::Base.extractor_for(response_set)
        handler.class.should == OperationalDataExtractor::Specimen
      end
    end

    context "with an adult urine instrument" do
      it "chooses the OperationalDataExtractor::Specimen" do
        survey = create_adult_urine_survey_with_specimen_operational_data
        response_set, instrument = prepare_instrument(person, participant, survey)
        handler = OperationalDataExtractor::Base.extractor_for(response_set)
        handler.class.should == OperationalDataExtractor::Specimen
      end
    end

    context "with a cord blood instrument" do
      it "chooses the OperationalDataExtractor::Specimen" do
        survey = create_cord_blood_survey_with_specimen_operational_data
        response_set, instrument = prepare_instrument(person, participant, survey)
        handler = OperationalDataExtractor::Base.extractor_for(response_set)
        handler.class.should == OperationalDataExtractor::Specimen
      end
    end

    context "with a tap water instrument" do
      it "chooses the OperationalDataExtractor::Sample" do
        survey = create_tap_water_survey_with_sample_operational_data
        response_set, instrument = prepare_instrument(person, participant, survey)
        handler = OperationalDataExtractor::Base.extractor_for(response_set)
        handler.class.should == OperationalDataExtractor::Sample
      end
    end

    context "with a vacuum bag dust instrument" do
      it "chooses the OperationalDataExtractor::Sample" do
        survey = create_vacuum_bag_dust_survey_with_sample_operational_data
        response_set, instrument = prepare_instrument(person, participant, survey)
        handler = OperationalDataExtractor::Base.extractor_for(response_set)
        handler.class.should == OperationalDataExtractor::Sample
      end
    end

  end

  context "processing the response set" do

    before(:each) do
      @person = Factory(:person)
      @participant = Factory(:participant)
      @survey = create_pregnancy_screener_survey_with_ppg_detail_operational_data
      @response_set, @instrument = prepare_instrument(@person, @participant, @survey)
      question = Factory(:question, :data_export_identifier => "PREG_SCREEN_HI_2.HOME_PHONE")
      answer = Factory(:answer, :response_class => "string")
      home_phone_response = Factory(:response, :string_value => "3125551212", :question => question, :answer => answer, :response_set => @response_set)

      @response_set.responses << home_phone_response
    end

    describe "#process" do

      before(:each) do
        OperationalDataExtractor::Base.process(@response_set)
      end

      it "creates only one data record for the extracted data" do
        person = Person.find(@person.id)
        phones = person.telephones
        phones.should_not be_empty
        phones.size.should == 1
        phones.first.phone_nbr.should == "3125551212"

        OperationalDataExtractor::Base.process(@response_set)
        person = Person.find(@person.id)
        person.telephones.should == phones
        person.telephones.first.phone_nbr.should == "3125551212"
      end

      it "updates one data record if re-processed" do
        person = Person.find(@person.id)
        phones = person.telephones
        phones.should_not be_empty
        phones.size.should == 1
        phones.first.phone_nbr.should == "3125551212"

        @response_set.responses.first.string_value = "3125556789"

        OperationalDataExtractor::Base.process(@response_set)
        person = Person.find(@person.id)
        person.telephones.should == phones
        person.telephones.first.phone_nbr.should == "3125556789"
      end
    end
  end

  context "processing addresses" do

    before do
      @person = Factory(:person)
      @rs = Factory(:response_set)
      @rs.person = @person
      @ode = OperationalDataExtractor::Base.new(@rs)
    end

    describe "#finalize_addresses" do
      before do
        @existing_business_address = Factory(:address, :address_rank_code => 1, :address_type_code => 2)
        @existing_school_address   = Factory(:address, :address_rank_code => 1, :address_type_code => 3)
        @new_business_address = Factory(:address, :address_rank_code => 4, :address_type_code => 2)
        @new_school_address   = Factory(:address, :address_rank_code => 4, :address_type_code => 3)
        @new_addresses = [ @new_business_address, @new_school_address]
        @person.addresses = [@existing_business_address, @existing_school_address]
      end

      it "demotes existing address in favor of new addresses of the same type" do
        @ode.finalize_addresses(@new_addresses)
        @existing_business_address.address_rank_code.should == 2
        @existing_school_address.address_rank_code.should   == 2
      end
    end

    describe "#which_addresses_changed" do
      before do
        @unchanged_address = Factory(:address, :state_code => -4)
        @changed_business_address = Factory(:address, :address_rank_code => 4, :address_type_code => 2)
        @changed_school_address   = Factory(:address, :address_rank_code => 4, :address_type_code => 3)
        @addresses = [@unchanged_address, @changed_business_address, @changed_school_address]
      end

      it "filters out a set of addresses with changed information" do
        @ode.which_addresses_changed(@addresses).should include(@changed_business_address, @changed_school_address)
        @ode.which_addresses_changed(@addresses).should_not include(@unchanged_address)
      end

      describe "#process_birth_institution_and_address" do

        before do
          @institution_map   = OperationalDataExtractor::PregnancyVisit::INSTITUTION_MAP
          @birth_address_map = OperationalDataExtractor::PregnancyVisit::BIRTH_ADDRESS_MAP

          @participant = Factory(:participant)
          @survey = create_pbs_pregnancy_visit_1_with_birth_institution_operational_data
          @response_set, @instrument = prepare_instrument(@person, @participant, @survey)

          hospital = NcsCode.for_list_name_and_local_code("ORGANIZATION_TYPE_CL1", 1)
          state = NcsCode.for_list_name_and_local_code("STATE_CL1", 14)

          take_survey(@survey, @response_set) do |a|
            a.choice "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.BIRTH_PLAN", hospital
            a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.BIRTH_PLACE", "FAKE HOSPITAL MEMORIAL"
            a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.B_ADDRESS_1", "123 Any Street"
            a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.B_CITY", "Springfield"
            a.choice "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.B_STATE", state
            a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.B_ZIPCODE", "65445"
          end
          @response_set.save!

          @ode2 = OperationalDataExtractor::PregnancyVisit.new(@response_set)
        end

        it "populates birth address record from instrument responses" do
          birth_address_and_institution = @ode2.process_birth_institution_and_address(@birth_address_map, @institution_map)
          birth_address = birth_address_and_institution[0]
          birth_address.class.should == Address
          birth_address.address_rank_code.should == 1
          birth_address.address_type_code.should == -5
          birth_address.address_one.should == "123 Any Street"
          birth_address.city.should == "Springfield"
          birth_address.zip.should == "65445"
          birth_address.address_type_other.should == "Birth"
        end

        it "returns a created institution" do
          birth_address_and_institution = @ode2.process_birth_institution_and_address(@birth_address_map, @institution_map)
          institution = birth_address_and_institution[1]
          institution.class.should == Institution
          institution.institute_name.should == "FAKE HOSPITAL MEMORIAL"
        end

      end

      describe "#get_address" do

        before do
          @person = Factory(:person)
          @response_set = Factory(:response_set)
          @code_address_type = NcsCode.for_list_name_and_local_code('ADDRESS_CATEGORY_CL1', 2)
          @address = Factory(:address,
                             :person => @person,
                             :response_set => @response_set,
                             :address_rank_code => 1,
                             :address_type_code => @code_address_type.local_code)

          @ode2 = OperationalDataExtractor::PbsEligibilityScreener.new(@response_set)
        end

        it "fetches an existing address record" do
          @ode2.get_address(@response_set, @person, @code_address_type).should == @address
        end

        it "creates a new record if it can't find an existing record" do
          @address = nil
          new_address = @ode2.get_address(@response_set, @person, @code_address_type)
          new_address.should_not == @address
          new_address.class.should == Address
        end
      end

    end

  end

  context "processing emails" do

    before do
      @person = Factory(:person)
      @survey = create_pbs_eligibility_screener_survey_with_email_operational_data
      @participant = Factory(:participant)
      @response_set, @instrument = prepare_instrument(@person, @participant, @survey)
      @personal_email_type_code = NcsCode.for_list_name_and_local_code('EMAIL_TYPE_CL1', 1)
      @work_email_type_code = NcsCode.for_list_name_and_local_code('EMAIL_TYPE_CL1', 2)
      @existing_work_email = Factory(  :email,
                                       :email => "existing_email@email.com",
                                       :person => @person,
                                       :response_set => @response_set,
                                       :email_rank_code => 1,
                                       :email_type_code => @work_email_type_code.local_code)

      @ode3 = OperationalDataExtractor::PbsEligibilityScreener.new(@response_set)
    end

    describe "#finalize_email" do
      before do
        @new_work_email          = Factory(:email,:email => "new_email@email.com",
                                           :email_rank_code => 4, :email_type_code => 2)
      end

      it "demotes existing email addresses in favor of new email addresses of the same type" do
        @ode3.finalize_email(@new_work_email)
        @existing_work_email.email_rank_code.should == 1
        updated_work_email = Email.find(@existing_work_email.id)
        updated_work_email.email_rank_code.should == 2
      end

    end

    describe "#process_email" do

      before do
        @map = OperationalDataExtractor::PbsEligibilityScreener::EMAIL_MAP

        question = Factory(:question, :data_export_identifier => "PBS_ELIG_SCREENER.R_EMAIL")
        answer = Factory(:answer, :response_class => "string")
        email_response = Factory(:response, :string_value => "some_email_address@email.com", :question => question, :answer => answer, :response_set => @response_set)

        @response_set.responses << email_response
      end

      it "creates an email record from the responses of am instrument" do
        email = @ode3.process_email(@map)
        email.email.should == "some_email_address@email.com"
      end

    end

    describe "#get_email" do

      it "retrieves an email record if one exists" do
        @ode3.get_email(@response_set, @person, @work_email_type_code).should == @existing_work_email
      end

      it "creates a new email record if one does not exist " do
        existing_email = @ode3.get_email(@response_set, @person, @work_email_type_code)
        existing_email.should == @existing_work_email
        new_email = @ode3.get_email(@response_set, @person, @personal_email_type_code)
        new_email.should_not == @existing_work_email
        new_email.class.should == Email
      end
    end

  end

  context "processing telephones" do

    before do
      @person = Factory(:person)
      @survey = create_pbs_eligibility_screener_survey_with_telephone_operational_data
      @participant = Factory(:participant)
      @response_set, @instrument = prepare_instrument(@person, @participant, @survey)
      @home_phone_type_code = NcsCode.for_list_name_and_local_code('PHONE_TYPE_CL1', 1)
      @work_phone_type_code = NcsCode.for_list_name_and_local_code('PHONE_TYPE_CL1', 2)
      @existing_home_phone = Factory(  :telephone,
                                       :phone_nbr => "666-666-6666",
                                       :person => @person,
                                       :response_set => @response_set,
                                       :phone_rank_code => 1,
                                       :phone_type_code => @home_phone_type_code.local_code)
      @existing_work_phone = Factory(  :telephone,
                                       :phone_nbr => "555-555-5555",
                                       :person => @person,
                                       :response_set => @response_set,
                                       :phone_rank_code => 1,
                                       :phone_type_code => @work_phone_type_code.local_code)
      @ode3 = OperationalDataExtractor::PbsEligibilityScreener.new(@response_set)
    end

    describe "#finalize_telephones" do
      before do
        @new_work_phone = Factory(:telephone, :phone_nbr => "888-888-8888", :phone_rank_code => 4, :phone_type_code => 2)
      end

      it "demotes existing telephone records in favor of new telephone records of the same type" do
        @existing_work_phone.phone_rank_code.should == 1
        @ode3.finalize_telephones(@new_work_phone)
        updated_work_phone = Telephone.find(@existing_work_phone.id)
        updated_work_phone.phone_rank_code.should == 2
      end

    end

    describe "#which_telephones_changed" do
      before do
        @unchanged_phone = Factory(:telephone, :phone_rank_code => 4, :phone_type_code => 1)
        @changed_home_phone = Factory(:telephone, :phone_nbr => "123-123-1234", :phone_rank_code => 4, :phone_type_code => 1)
        @changed_work_phone = Factory(:telephone, :phone_nbr => "999-999-9999", :phone_rank_code => 4, :phone_type_code => 2)
        @phones = [@unchanged_phone, @changed_home_phone, @changed_work_phone]
      end

      it "filters out a set of addresses with changed information" do
        @ode3.which_telephones_changed(@phones).should include(@changed_work_phone, @changed_home_phone)
        @ode3.which_telephones_changed(@phones).should_not include(@unchanged_unchanged_phone)
      end
    end

    describe "#process_telephone" do

      before do
        @map = OperationalDataExtractor::PbsEligibilityScreener::TELEPHONE_MAP1

        question = Factory(:question, :data_export_identifier => "PBS_ELIG_SCREENER.R_PHONE_1")
        answer = Factory(:answer, :response_class => "string")
        phone_number_response = Factory(:response, :string_value => "484-484-4848", :question => question, :answer => answer, :response_set => @response_set)
        question = Factory(:question, :data_export_identifier => "PBS_ELIG_SCREENER.R_PHONE_TYPE1")
        answer = Factory(:answer, :response_class => "string")
        phone_type_response = Factory(:response, :string_value => "Home", :question => question, :answer => answer, :response_set => @response_set)

        @response_set.responses << phone_number_response << phone_type_response
      end

      it "creates a phone record from the responses of an instrument" do
        phone = @ode3.process_telephone(@person, @map)
        phone.phone_nbr.should == "4844844848"
      end

    end

    describe "#get_telephone" do

      it "retrieves an phone record if one exists" do
        @ode3.get_telephone(@response_set, @person, @work_phone_type_code).should == @existing_work_phone
      end

      it "creates a new phone record if one does not exist " do
        existing_phone = @ode3.get_telephone(@response_set, @person, @work_phone_type_code)
        existing_phone.should == @existing_work_phone
        new_phone = @ode3.get_telephone(@response_set, @person, @home_phone_type_code)
        new_phone.should_not == @existing_work_phone
        new_phone.class.should == Telephone
      end
    end

  end

  context "processing birth institution and address" do

    let(:hospital_type_location) { NcsCode.for_list_name_and_local_code("ORGANIZATION_TYPE_CL1", 1) }

    before do
      @institution_map   = OperationalDataExtractor::PregnancyVisit::INSTITUTION_MAP
      @birth_address_map = OperationalDataExtractor::PregnancyVisit::BIRTH_ADDRESS_MAP

      @person = Factory(:person)
      @participant = Factory(:participant)
      @part_person_link = Factory(:participant_person_link, :participant => @participant, :person => @person)
      @survey = create_pbs_pregnancy_visit_1_with_birth_institution_operational_data
      @response_set, @instrument = prepare_instrument(@person, @participant, @survey)

      hospital = NcsCode.for_list_name_and_local_code("ORGANIZATION_TYPE_CL1", 1)
      state = NcsCode.for_list_name_and_local_code("STATE_CL1", 14)

      take_survey(@survey, @response_set) do |a|
        a.choice "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.BIRTH_PLAN", hospital
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.BIRTH_PLACE", "FAKE HOSPITAL MEMORIAL"
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.B_ADDRESS_1", "123 Any Street"
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.B_CITY", "Springfield"
        a.choice "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.B_STATE", state
        a.str "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.B_ZIPCODE", "65445"
      end
      @response_set.save!

      @ode1 = OperationalDataExtractor::PregnancyVisit.new(@response_set)
      @birth_address, @institution = @ode1.process_birth_institution_and_address(@birth_address_map, @institution_map)
    end

    describe "#process_institution" do
      it "generates an instituiton record" do
        @ode1.process_institution(@institution_map).class.should == Institution
        @ode1.process_institution(@institution_map).institute_name.should == "FAKE HOSPITAL MEMORIAL"
      end
    end

    describe "#address_empty?" do

      it "should return true if all the survey-derived components of an address are empty" do
        address = Address.new
        @ode1.address_empty?(address).should be_true
      end

      it "should return false if any survey-derived components of an address are not empty" do
        address = Factory(:address, :address_one => "123 Something Street")
        @ode1.address_empty?(address).should be_false
      end

    end

    describe "#institution_empty?" do

      it "should return true if all the survey-derived components of an institution are empty" do
        institution = Institution.new
        @ode1.institution_empty?(institution).should be_true
      end

      it "should return false if any survey-derived components of an institution are not empty" do
        institution = Factory(:institution, :institute_name => "FAKE INSTITUTION")
        @ode1.institution_empty?(institution).should be_false
      end

    end

    describe "#finalize_institution" do
      it "links the person to the institution" do
        institution = @ode1.process_institution(@institution_map)
        @ode1.finalize_institution(institution)
        @participant.person.institutions.first.should eq(institution)
      end

      it "saves the institution record" do
        institution = @ode1.process_institution(@institution_map)
        Institution.count.should == 0
        @ode1.finalize_institution(institution)
        Institution.count.should == 1
        Institution.first.should eq(institution)
      end

    end

    describe "#finalize_institution_with_birth_address" do

      it "creates a institution-person link" do
        InstitutionPersonLink.count.should == 0
        @ode1.finalize_institution_with_birth_address(@birth_address, @institution)
        InstitutionPersonLink.count.should == 1
      end

      it "creates a birth institution record" do
        Institution.count.should == 0
        @ode1.finalize_institution_with_birth_address(@birth_address, @institution)
        Institution.count.should == 1
        @institution.addresses.should include(@birth_address)
      end

    end

  end
end
