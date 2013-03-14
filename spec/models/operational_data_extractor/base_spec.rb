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

    context "with a child blood instrument" do
      it "chooses the OperationalDataExtractor::Specimen" do
        survey = create_child_blood_survey_with_specimen_operational_data
        response_set, instrument = prepare_instrument(person, participant, survey)
        handler = OperationalDataExtractor::Base.extractor_for(response_set)
        handler.class.should == OperationalDataExtractor::Specimen
      end
    end

    context "with a child saliva instrument" do
      it "chooses the OperationalDataExtractor::Specimen" do
        survey = create_child_saliva_survey_with_specimen_operational_data
        response_set, instrument = prepare_instrument(person, participant, survey)
        handler = OperationalDataExtractor::Base.extractor_for(response_set)
        handler.class.should == OperationalDataExtractor::Specimen
      end
    end

    context "with a child urine instrument" do
      it "chooses the OperationalDataExtractor::Specimen" do
        survey = create_child_urine_survey_with_specimen_operational_data
        response_set, instrument = prepare_instrument(person, participant, survey)
        handler = OperationalDataExtractor::Base.extractor_for(response_set)
        handler.class.should == OperationalDataExtractor::Specimen
      end
    end

    context "with a breast milk instrument" do
      it "chooses the OperationalDataExtractor::Specimen" do
        survey = create_breast_milk_survey_with_specimen_operational_data
        response_set, instrument = prepare_instrument(person, participant, survey)
        handler = OperationalDataExtractor::Base.extractor_for(response_set)
        handler.class.should == OperationalDataExtractor::Specimen
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

    context "with a sample kit distribution instrument" do
      it "chooses the OperationalDataExtractor::Sample" do
        survey = create_sample_distrib_survey_with_sample_operational_data
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
      @base_extractor = OperationalDataExtractor::Base.new(@rs)
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
        @base_extractor.finalize_addresses(@new_addresses)
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
        @base_extractor.which_addresses_changed(@addresses).should include(@changed_business_address, @changed_school_address)
        @base_extractor.which_addresses_changed(@addresses).should_not include(@unchanged_address)
      end

      describe "#process_birth_institution_and_address" do

        before do
          @institution_map   = OperationalDataExtractor::PregnancyVisit::INSTITUTION_MAP
          @birth_address_map = OperationalDataExtractor::PregnancyVisit::BIRTH_ADDRESS_MAP

          @participant = Factory(:participant)
          @part_person_link = Factory(:participant_person_link, :participant => @participant, :person => @person)
          @survey = create_pbs_pregnancy_visit_1_with_birth_institution_operational_data
          @response_set, @instrument = prepare_instrument(@person, @participant, @survey)

          hospital = NcsCode.for_list_name_and_local_code("ORGANIZATION_TYPE_CL1", 1)
          state = NcsCode.for_list_name_and_local_code("STATE_CL1", 14)

          take_survey(@survey, @response_set) do |r|
            r.a "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.BIRTH_PLAN", hospital
            r.a "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.BIRTH_PLACE", "FAKE HOSPITAL MEMORIAL"
            r.a "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.B_ADDRESS_1", "123 Any Street"
            r.a "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.B_CITY", "Springfield"
            r.a "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.B_STATE", state
            r.a "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.B_ZIPCODE", "65445"
          end
          @response_set.save!

          @pregnancy_visit_extractor = OperationalDataExtractor::PregnancyVisit.new(@response_set)
        end

        it "populates birth address record from instrument responses" do
          birth_address_and_institution = @pregnancy_visit_extractor.process_birth_institution_and_address(@birth_address_map, @institution_map)
          birth_address = birth_address_and_institution[0]
          birth_address.should be_an_instance_of(Address)
          birth_address.address_rank_code.should == 1
          birth_address.address_type_code.should == -5
          birth_address.address_one.should == "123 Any Street"
          birth_address.city.should == "Springfield"
          birth_address.zip.should == "65445"
          birth_address.address_type_other.should == "Birth"
        end

        it "returns a created institution" do
          birth_address_and_institution = @pregnancy_visit_extractor.process_birth_institution_and_address(@birth_address_map, @institution_map)
          institution = birth_address_and_institution[1]
          institution.should be_an_instance_of(Institution)
          institution.institute_name.should == "FAKE HOSPITAL MEMORIAL"
        end

        context "birth place name doesn't exist" do
          it "doesn't return an institution" do
            @response_set.responses.delete(
              @response_set.responses.where(
                :questions => {:data_export_identifier => "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.BIRTH_PLACE"})
            )
            take_survey(@survey, @response_set) do |r|
              r.refused "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.BIRTH_PLACE"
            end
            @response_set.save!
            birth_address_and_institution = @pregnancy_visit_extractor.process_birth_institution_and_address(@birth_address_map, @institution_map)
            birth_address_and_institution[1].should be_nil
          end
        end

        context "when no response for birth plan" do
          it "returns institution as nil" do
            @response_set.responses.delete(
              @response_set.responses.where(
                :questions => {:data_export_identifier => "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.BIRTH_PLAN"})
            )
            @response_set.save!
            birth, institution = @pregnancy_visit_extractor.process_institution(@institution_map, @response_set)
            institution.should be_nil
          end
        end

        context "when birth plan is refused" do
          it "returns institution as nil" do
            @response_set.responses.delete(
              @response_set.responses.where(
                :questions => {:data_export_identifier => "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.BIRTH_PLAN"})
            )
            take_survey(@survey, @response_set) do |r|
              r.refused "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.BIRTH_PLAN"
            end
            @response_set.save!
            birth, institution = @pregnancy_visit_extractor.process_institution(@institution_map, @response_set)
            institution.should be_nil
          end
        end
      end

      describe "#get_address" do

        before do
          @person = Factory(:person)
          @response_set = Factory(:response_set)
          @primary_rank = NcsCode.for_list_name_and_local_code('COMMUNICATION_RANK_CL1', 1)
          @code_address_type = NcsCode.for_list_name_and_local_code('ADDRESS_CATEGORY_CL1', 2)
          @address = Factory(:address,
                             :person => @person,
                             :response_set => @response_set,
                             :address_rank_code => 1,
                             :address_type_code => @code_address_type.local_code)

          @pbs_eligibility_extractor = OperationalDataExtractor::PbsEligibilityScreener.new(@response_set)
        end

        it "fetches an existing address record" do
          @pbs_eligibility_extractor.get_address(@response_set, @person, @code_address_type, @primary_rank).should == @address
        end

        it "creates a new record if it can't find an existing record" do
          @address = nil
          new_address = @pbs_eligibility_extractor.get_address(@response_set, @person, @code_address_type, @primary_rank)
          new_address.should_not == @address
          new_address.should be_an_instance_of(Address)
        end

        describe "get_birth_address" do

          before do
            @person = Factory(:person)
            @participant = Factory(:participant)
            @part_person_link = Factory(:participant_person_link, :participant => @participant, :person => @person)
            @response_set = Factory(:response_set)
            @birth_address = Factory(:address,
                               :person => @person,
                               :response_set => @response_set,
                               :address_rank_code => 1,
                               :address_type_code => @code_address_type.local_code,
                               :address_type_other => "Birth")

            @pbs_eligibility_extractor = OperationalDataExtractor::PbsEligibilityScreener.new(@response_set)
          end

          it "fetches an existing address record" do
            @pbs_eligibility_extractor.get_address(@response_set, @person, @code_address_type, @primary_rank).should == @birth_address
          end

          it "creates a new record if it can't find an existing record" do
            @birth_address = nil
            new_address = @pbs_eligibility_extractor.get_address(@response_set, @person, @code_address_type, @primary_rank)
            new_address.should_not == @birth_address
            new_address.should be_an_instance_of(Address)
          end

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

      @pbs_eligibility_extractor = OperationalDataExtractor::PbsEligibilityScreener.new(@response_set)
    end

    describe "#finalize_email" do
      before do
        @new_work_email          = Factory(:email,:email => "new_email@email.com",
                                           :email_rank_code => 4, :email_type_code => 2)
      end

      it "demotes existing email addresses in favor of new email addresses of the same type" do
        @pbs_eligibility_extractor.finalize_email(@new_work_email)
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
        email = @pbs_eligibility_extractor.process_email(@map)
        email.email.should == "some_email_address@email.com"
      end

    end

    describe "#get_email" do

      it "retrieves an email record if one exists" do
        @pbs_eligibility_extractor.get_email(@response_set, @person, @work_email_type_code).should == @existing_work_email
      end

      it "creates a new email record if one does not exist " do
        existing_email = @pbs_eligibility_extractor.get_email(@response_set, @person, @work_email_type_code)
        existing_email.should == @existing_work_email
        new_email = @pbs_eligibility_extractor.get_email(@response_set, @person, @personal_email_type_code)
        new_email.should_not == @existing_work_email
        new_email.should be_an_instance_of(Email)
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
      @pbs_eligibility_extractor = OperationalDataExtractor::PbsEligibilityScreener.new(@response_set)
    end

    describe "#finalize_telephones" do
      before do
        @new_work_phone = Factory(:telephone, :phone_nbr => "888-888-8888", :phone_rank_code => 4, :phone_type_code => 2)
      end

      it "demotes existing telephone records in favor of new telephone records of the same type" do
        @existing_work_phone.phone_rank_code.should == 1
        @pbs_eligibility_extractor.finalize_telephones(@new_work_phone)
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
        @pbs_eligibility_extractor.which_telephones_changed(@phones).should include(@changed_work_phone, @changed_home_phone)
        @pbs_eligibility_extractor.which_telephones_changed(@phones).should_not include(@unchanged_unchanged_phone)
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
        phone = @pbs_eligibility_extractor.process_telephone(@person, @map)
        phone.phone_nbr.should == "4844844848"
      end

    end

    describe "#get_telephone" do

      it "retrieves an phone record if one exists" do
        @pbs_eligibility_extractor.get_telephone(@response_set, @person, @work_phone_type_code).should == @existing_work_phone
      end

      it "creates a new phone record if one does not exist " do
        existing_phone = @pbs_eligibility_extractor.get_telephone(@response_set, @person, @work_phone_type_code)
        existing_phone.should == @existing_work_phone
        new_phone = @pbs_eligibility_extractor.get_telephone(@response_set, @person, @home_phone_type_code)
        new_phone.should_not == @existing_work_phone
        new_phone.should be_an_instance_of(Telephone)
      end
    end

  end

  context "processing birth institution" do

    let(:hospital_type_location) { NcsCode.for_list_name_and_local_code("ORGANIZATION_TYPE_CL1", 1) }

    before do
      @institution_map   = OperationalDataExtractor::PregnancyVisit::INSTITUTION_MAP
      @birth_address_map = OperationalDataExtractor::PregnancyVisit::BIRTH_ADDRESS_MAP

      @person = Factory(:person)
      @participant = Factory(:participant)
      @part_person_link = Factory(:participant_person_link, :participant => @participant, :person => @person)
      @survey = create_pbs_pregnancy_visit_1_with_birth_institution_operational_data
      @response_set, @instrument = prepare_instrument(@person, @participant, @survey)

      @hospital = NcsCode.for_list_name_and_local_code("ORGANIZATION_TYPE_CL1", 1)
      state = NcsCode.for_list_name_and_local_code("STATE_CL1", 14)

      take_survey(@survey, @response_set) do |r|
        r.a "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.BIRTH_PLAN", @hospital
        r.a "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.BIRTH_PLACE", "FAKE HOSPITAL MEMORIAL"
        r.a "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.B_ADDRESS_1", "123 Any Street"
        r.a "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.B_CITY", "Springfield"
        r.a "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.B_STATE", state
        r.a "#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX}.B_ZIPCODE", "65445"
      end
      @response_set.save!

      @pregnancy_visit_extractor = OperationalDataExtractor::PregnancyVisit.new(@response_set)
    end

    describe "#find_or_build_institution" do

      it "generates a new institution record if one does not exist" do
        institution = @pregnancy_visit_extractor.find_or_build_institution(@response_set, @hospital)
        institution.should be_an_instance_of(Institution)
      end

      it "the new record should be associated with the response set" do
        @pregnancy_visit_extractor.find_or_build_institution(@response_set, @hospital).response_set.should eq(@response_set)
      end

      it "retrieves an institution record if one exists" do
        @existing_institution = Factory(:institution, :institute_type => @hospital, :response_set_id => @response_set.id)
        @pregnancy_visit_extractor.find_or_build_institution(@response_set, @hospital).should eql(@existing_institution)
      end
    end

    describe "#process_institution" do
      it "generates an instituiton record" do
        @pregnancy_visit_extractor.process_institution(@institution_map, @response_set).should be_an_instance_of(Institution)
        @pregnancy_visit_extractor.process_institution(@institution_map, @response_set).institute_name.should == "FAKE HOSPITAL MEMORIAL"
      end

      it "has nil institution"
      
    end

    describe "#finalize_institution" do

      let(:institution) { @pregnancy_visit_extractor.process_institution(@institution_map, @response_set) }

      it "links the person to the institution" do
        @pregnancy_visit_extractor.finalize_institution(institution)
        @participant.person.institutions.first.should eq(institution)
      end

      it "saves the institution record" do
        @pregnancy_visit_extractor.finalize_institution(institution)
        Institution.count.should == 1
        Institution.first.should eq(institution)
      end

      it "does not create a duplicate institution-person link if one already exists" do
        (2).times do
          @pregnancy_visit_extractor.finalize_institution(institution)
        end
        InstitutionPersonLink.where(:person_id => @person.id, :institution_id => institution.id).size.should == 1
      end

      context "institution is nil" do
        it "does not link the institution record" do
          @pregnancy_visit_extractor.finalize_institution(nil)
          @participant.person.institutions.first.should eq(nil)
        end

        it "does not create an institution record" do
          @pregnancy_visit_extractor.finalize_institution(nil)
          Institution.count.should == 0
        end
      end
    end

    describe "#finalize_institution_with_birth_address" do

      it "creates a institution-person link" do
        birth_address, institution = @pregnancy_visit_extractor.process_birth_institution_and_address(@birth_address_map, @institution_map)
        @pregnancy_visit_extractor.finalize_institution_with_birth_address(@birth_address, institution)
        InstitutionPersonLink.count.should == 1
      end

      it "creates a birth institution record" do
        birth_address, institution = @pregnancy_visit_extractor.process_birth_institution_and_address(@birth_address_map, @institution_map)
        @pregnancy_visit_extractor.finalize_institution_with_birth_address(birth_address, institution)
        Institution.count.should == 1
        institution.addresses.should include(birth_address)
      end

      context "institution is nil" do
        it "does not create an institution record" do
          @pregnancy_visit_extractor.finalize_institution_with_birth_address(@birth_address, nil)
          Institution.count.should == 0
        end
        it "does nothing if institution is nil" do
          @pregnancy_visit_extractor.finalize_institution_with_birth_address(@birth_address, nil)
          InstitutionPersonLink.count.should == 0
        end
      end
    end
  end

  context "Processing PersonRace records" do
    let(:white_race) { NcsCode.for_list_name_and_local_code("RACE_CL1", 1) }
    let(:black_race) { NcsCode.for_list_name_and_local_code("RACE_CL1", 2) }
    let(:asian_race) { NcsCode.for_list_name_and_local_code("RACE_CL1", 4) }
    let(:other_race) { NcsCode.for_list_name_and_local_code("RACE_CL1", -5) }
    let(:vietnamese_race) { NcsCode.for_list_name_and_local_code("RACE_CL6", 9) }
    let(:filipino_race) { NcsCode.for_list_name_and_local_code("RACE_CL7", 3) }
    let(:asian_indian_race) { NcsCode.for_list_name_and_local_code("RACE_CL7", 1) }
    let(:samoan_race) { NcsCode.for_list_name_and_local_code("RACE_CL8", 3) }
    let(:native_hawaiian_race) { NcsCode.for_list_name_and_local_code("RACE_CL8", 1) }

    before do
      @person_race_map = OperationalDataExtractor::Birth::PERSON_RACE_MAP

      @person = Factory(:person)
      @participant = Factory(:participant)
      Factory(:participant_person_link, :participant => @participant, :person => @person)
      @survey = create_birth_survey_with_person_race_operational_data
      @response_set, instrument = prepare_instrument(@person, @participant, @survey)

      take_survey(@survey, @response_set) do |r|
        r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_BABY_RACE_NEW_3_PREFIX}.BABY_RACE_NEW", white_race
        r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_BABY_RACE_NEW_3_PREFIX}.BABY_RACE_NEW_OTH", "Chinese"
        r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_BABY_RACE_1_3_PREFIX}.BABY_RACE_1", black_race
        r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_BABY_RACE_1_3_PREFIX}.BABY_RACE_1_OTH", "Korean"
      end

      @response_set.save!

      @birth_extractor = OperationalDataExtractor::Birth.new(@response_set)
    end

    describe "#process_person_race" do
      context "when there is only a single response for a given question" do
        it "directs non _new type race export identifiers to #process_standard_race" do
          @birth_extractor.should_receive(:process_standard_race).twice
          @birth_extractor.process_person_race(@person_race_map)
        end

        it "directs _new type race export identifiers to #process_new_type_race" do
          @birth_extractor.should_receive(:process_new_type_race).twice
          @birth_extractor.process_person_race(@person_race_map)
        end
      end

      context "when there are multiple responses for a given question" do
        before do
          @response_set_multiple_responses, instrument = prepare_instrument(@person, @participant, @survey)

          take_survey(@survey, @response_set_multiple_responses) do |r|
            r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_BABY_RACE_NEW_3_PREFIX}.BABY_RACE_NEW", white_race
            r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_BABY_RACE_NEW_3_PREFIX}.BABY_RACE_NEW", black_race
            r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_BABY_RACE_NEW_3_PREFIX}.BABY_RACE_NEW", asian_race
          end
          @response_set_multiple_responses.save!

          @multiple_response_birth_extractor = OperationalDataExtractor::Birth.new(@response_set_multiple_responses)
        end

        it "calls race record generation method for each response" do
          @multiple_response_birth_extractor.should_not_receive(:process_standard_race)
          @multiple_response_birth_extractor.should_receive(:process_new_type_race).exactly(3).times
          @multiple_response_birth_extractor.process_person_race(@person_race_map)
        end

        it "saves all the records" do
          @multiple_response_birth_extractor.process_person_race(@person_race_map)
          @person.races.count.should == 3
        end
      end

      context "when some of the responses are new_type and some are of standard type" do
        before do
          @response_set_multiple_mixed_type, instrument = prepare_instrument(@person, @participant, @survey)

          take_survey(@survey, @response_set_multiple_mixed_type) do |r|
            r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_BABY_RACE_NEW_3_PREFIX}.BABY_RACE_NEW", white_race
            r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_BABY_RACE_1_3_PREFIX}.BABY_RACE_1", black_race
          end
          @response_set_multiple_mixed_type.save!

          @birth_extractor_multiple_mixed_type = OperationalDataExtractor::Birth.new(@response_set_multiple_mixed_type)
        end

        it "calls the right race record generation method for each response type" do
          @birth_extractor_multiple_mixed_type.should_receive(:process_new_type_race).once
          @birth_extractor_multiple_mixed_type.should_receive(:process_standard_race).once
          @birth_extractor_multiple_mixed_type.process_person_race(@person_race_map)
        end

        it "saves all the records" do
          @birth_extractor_multiple_mixed_type.process_person_race(@person_race_map)
          @person.races.count.should == 2
        end
      end

      context "when some of the new_type responses match to standard code list values and some do not" do
        before do
          @response_set_on_and_off_code_list, instrument = prepare_instrument(@person, @participant, @survey)

          take_survey(@survey, @response_set_on_and_off_code_list) do |r|
            r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_BABY_RACE_NEW_3_PREFIX}.BABY_RACE_NEW", white_race
            r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_BABY_RACE_NEW_3_PREFIX}.BABY_RACE_NEW", vietnamese_race
          end
          @response_set_on_and_off_code_list.save!

          @on_and_off_code_list_birth_extractor = OperationalDataExtractor::Birth.new(@response_set_on_and_off_code_list)
        end

        it "calls the right race record generation method for each response type" do
          @on_and_off_code_list_birth_extractor.should_receive(:process_new_type_race).twice
          @on_and_off_code_list_birth_extractor.process_person_race(@person_race_map)
        end

        it "saves all the records" do
          @on_and_off_code_list_birth_extractor.process_person_race(@person_race_map)
          @person.races.count.should == 2

        end

        it "specifies the response that matches the standard code list as its integer code value" do
          @on_and_off_code_list_birth_extractor.process_person_race(@person_race_map)
          white_race_record = @person.races.detect { |race| race.race_code == 1 }
          white_race_record.race_code.should == 1
          white_race_record.race_other.should be_nil
        end

        it "specifies the response that does not match the standard code list as the text value associated with its code on the new type code list (CL6) " do
          @on_and_off_code_list_birth_extractor.process_person_race(@person_race_map)
          other_race_record = @person.races.detect { |race| race.race_code == -5 }
          other_race_record.race_code.should == -5
          other_race_record.race_other.should == "Vietnamese"
        end
      end

      context "when the response is an other race value, for standard race type" do
        before do
          @response_set_other_race_type, instrument = prepare_instrument(@person, @participant, @survey)

          take_survey(@survey, @response_set_other_race_type) do |r|
            r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_BABY_RACE_1_3_PREFIX}.BABY_RACE_1", other_race
            r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_BABY_RACE_1_3_PREFIX}.BABY_RACE_1_OTH", "Aborigine"
          end
          @response_set_other_race_type.save!

          @birth_extractor_other_race_type = OperationalDataExtractor::Birth.new(@response_set_other_race_type)
        end

        it "calls the right race record generation method for each response type" do
          @birth_extractor_other_race_type.should_receive(:process_standard_race).twice
          @birth_extractor_other_race_type.process_person_race(@person_race_map)
        end

        it "saves all the records" do
          @birth_extractor_other_race_type.process_person_race(@person_race_map)
          @person.races.count.should == 1
        end

        it "a record with the response of other(-5) should have -5 and the other description on the same race record" do
          @birth_extractor_other_race_type.process_person_race(@person_race_map)
          @person.races.first.race_code.should == -5
          @person.races.first.race_other.should == "Aborigine"
        end

      end
    end

    describe "#process_new_type_race" do
      before do
        @blank_person_race = Factory(:person_race, :race_code => nil)
      end

      context "when the response is part of the code list associated with the model (RACE_CL1 from MDES spreadsheet)" do

        it "populates a 'new' type PersonRace race_code attribute with the code value" do
          attribute = "race_code"
          answer = mock_model(Answer, :reference_identifier => "3", :response_class => "answer")
          response = mock_model(Response, :answer => answer)
          @birth_extractor.process_new_type_race(@blank_person_race, attribute, response)
          @blank_person_race.race_code.should == 3
        end
      end

      context "when the record is not part of the code list associated with the model (RACE_CL1 from MDES spreadsheet)" do

        before do
          attribute = "race_code"
          answer = mock_model(Answer, :reference_identifier => "8", :response_class => "answer", :text => "Korean")
          response = mock_model(Response, :answer => answer)
          @birth_extractor.process_new_type_race(@blank_person_race, attribute, response)
        end

        it "populates a 'new' type PersonRace race_code attribute with the code value for 'other' (-5)" do
          @blank_person_race.race_code.should == -5
        end

        it "populates a 'new' type PersonRace race_other attribute with the text value of the response" do
          @blank_person_race.race_other.should == "Korean"
        end
      end
    end

    describe "#process_standard_race" do
      let(:general_question) { Factory(:question, :reference_identifier => "BABY_RACE_1") }
      let(:general_answer)   { Factory(:answer, :reference_identifier => "4", :response_class => "answer", :text => "Asian")}
      let(:general_response) { Factory(:response, :question => general_question, :answer => general_answer)}

      let(:specific_asian_question) { Factory(:question, :reference_identifier => "BABY_RACE_2") }
      let(:specific_asian_answer)   { Factory(:answer, :reference_identifier => "3", :response_class => "answer", :text => "Filipino")}
      let(:specific_asian_response) { Factory(:response, :question => specific_asian_question, :answer => specific_asian_answer)}

      let(:specific_pacific_islander_question) { Factory(:question, :reference_identifier => "BABY_RACE_3") }
      let(:specific_pacific_islander_answer)   { Factory(:answer, :reference_identifier => "3", :response_class => "answer", :text => "Native Hawaiian")}
      let(:specific_pacific_islander_response) { Factory(:response, :question => specific_pacific_islander_question, :answer => specific_pacific_islander_answer)}

      before do
        @blank_person_race = Factory(:person_race, :race_code => nil)
      end

      context "when it is a general race response" do
        it "populates a race code with the response reference id" do
          attribute = "race_code"
          @birth_extractor.process_standard_race(@blank_person_race, attribute, general_response)
          @blank_person_race.race_code.should == 4
        end
      end

      context "when it is a more specific asian race response" do

        it "populates race_code attribute with the code value for 'other' (-5)" do
          attribute = "race_code"
          @birth_extractor.process_standard_race(@blank_person_race, attribute, specific_asian_response)
          @blank_person_race.race_code.should == -5
        end

        it "populates race_other attribute with the text value of the response" do
          attribute = "race_other"
          @birth_extractor.process_standard_race(@blank_person_race, attribute, specific_asian_response)
          @blank_person_race.race_other.should == "Filipino"
        end
      end

      context "when it is a more specific pacific islander race response" do

        it "populates race_code attribute with the code value for 'other' (-5)" do
          attribute = "race_code"
          @birth_extractor.process_standard_race(@blank_person_race, attribute, specific_pacific_islander_response)
          @blank_person_race.race_code.should == -5
        end

        it "populates race_other attribute with the text value of the response" do
          attribute = "race_other"
          @birth_extractor.process_standard_race(@blank_person_race, attribute, specific_pacific_islander_response)
          @blank_person_race.race_other.should == "Native Hawaiian"
        end
      end
    end

    describe "#collect_pick_any_responses" do
      before do
        @response_set2, instrument = prepare_instrument(@person, @participant, @survey)
        take_survey(@survey, @response_set2) do |r|
          r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_BABY_RACE_NEW_3_PREFIX}.BABY_RACE_NEW", white_race
          r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_BABY_RACE_NEW_3_PREFIX}.BABY_RACE_NEW", black_race
          r.a "#{OperationalDataExtractor::Birth::BIRTH_VISIT_BABY_RACE_NEW_3_PREFIX}.BABY_RACE_NEW", asian_race
        end
        @response_set2.save!
        @birth_extractor2 = OperationalDataExtractor::Birth.new(@response_set2)
      end

      it "collects all the race-related responses" do
        resps = @birth_extractor2.collect_pick_any_responses("#{OperationalDataExtractor::Birth::BIRTH_VISIT_BABY_RACE_NEW_3_PREFIX}.BABY_RACE_NEW")
        resps.count.should  == 3
        resps.first.should be_instance_of(Response)
        resps.first.question.data_export_identifier.should =~ /RACE/
      end
    end

    describe "#get_person_race" do
      let(:question) { Factory(:question) }
      let(:answer)   { Factory(:answer, :reference_identifier => "-5",  :text => "Other")}
      let(:response) { Factory(:response, :question => question, :answer => answer)}

      before do
        @birth_extractor = OperationalDataExtractor::Birth.new(@response_set)
      end

      it "returns an existing person race record when the is one that contains an other choice selection, yet whose other text description is blank" do
        other_with_no_description = @person.races.create(:race_code => -5, :race_other => nil)
        @birth_extractor.get_person_race(response).should eql(other_with_no_description)
      end

      it "returns a new person race record when a record of the above description does not exist" do
        person_race = @birth_extractor.get_person_race(response)
        person_race.should be_instance_of(PersonRace)
        person_race.new_record?.should be_true
      end
    end

    describe "record duplication" do

      it "does not create a person race record if one already exists" do
        (2).times do
          @birth_extractor.process_person_race(@person_race_map)
        end

        PersonRace.where(:person_id => @person.id, :race_code => white_race.local_code).size.should == 1
      end
    end
  end

end
