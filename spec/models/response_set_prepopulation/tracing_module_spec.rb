require 'spec_helper'

require File.expand_path('../a_survey_title_acceptor', __FILE__)

module ResponseSetPrepopulation
  describe TracingModule do
    include SurveyCompletion

    context 'class' do
      let(:populator) { TracingModule }

      it_should_behave_like 'a survey title acceptor', '_Tracing_'
    end

    def init_instrument_and_response_set(event = nil,
                to_call = :create_tracing_survey_with_prepopulated_fields)
      @survey = method(to_call).call
      # method can be invoked multiple times and survey access code must be unique
      @survey.access_code = SecureRandom.base64
      @survey.save!
      @response_set, @instrument = prepare_instrument(@person, @participant, @survey, nil, event)
      # sanity check that there are no responses in response set
      @response_set.responses.should be_empty
    end

    def run_populator(event = nil, mode = nil)
      init_instrument_and_response_set(event)
      TracingModule.new(@response_set).tap do |p|
        p.mode = mode
      end.run
    end

    context "with tracing instrument" do

      before(:each) do
        @person = Factory(:person)
        @participant = Factory(:participant)
        @ppl = Factory(:participant_person_link, :participant => @participant, :person => @person, :relationship_code => 1)
      end

      describe "for a contact that is" do
        describe "in person" do
          it "prepopulated_mode_of_contact is set to CAPI" do
            run_populator(nil, Instrument.capi)
            assert_response_value(@response_set, "prepopulated_mode_of_contact", "CAPI")
          end
        end

        describe "via telephone" do
          it "prepopulated_mode_of_contact is set to CATI" do
            run_populator(nil, Instrument.cati)
            assert_response_value(@response_set, "prepopulated_mode_of_contact", "CATI")
          end
        end

      end

      describe "event type" do
        it "should be birth event if EVENT_TYPE = BIRTH" do
          event = Factory(:event, :event_type_code => 18) # Birth
          run_populator(event)
          assert_response_value(@response_set, "prepopulated_is_event_type_birth", "TRUE")
        end

        it "should NOT be birth event if EVENT_TYPE is not BIRTH" do
          event = Factory(:event, :event_type_code => 13) # NOT Birth
          run_populator(event)
          assert_response_value(@response_set, "prepopulated_is_event_type_birth", "FALSE")
        end

        it "should be PBS Eligibility Screener if EVENT_TYPE = PBS ELIGIBILITY SCREENING" do
          event = Factory(:event, :event_type_code => 34) # Eligibility Screener
          run_populator(event)
          assert_response_value(@response_set, "prepopulated_is_event_type_pbs_participant_eligibility_screening", "TRUE")

        end

        it "should NOT be PBS Eligibility Screener if EVENT_TYPE is not PBS ELIGIBILITY SCREENING" do
          event = Factory(:event, :event_type_code => 13) # NOT Eligibility Screener
          run_populator(event)
          assert_response_value(@response_set, "prepopulated_is_event_type_pbs_participant_eligibility_screening", "FALSE")
        end
      end

      describe "prepopulate address information" do
        before(:each) do
          init_instrument_and_response_set(nil,
               :create_tracing_module_survey_with_address_operational_data)
          take_survey(@survey, @response_set) do |r|
            r.a "TRACING_INT.ADDRESS_1", 'string', :value => 'Address One'
            r.a "TRACING_INT.ADDRESS_2", 'string', :value => '123'
            r.a "TRACING_INT.UNIT", 'string', :value => '321'
            r.a "TRACING_INT.CITY", 'string', :value => 'Chicago'
            r.a "TRACING_INT.STATE", { :reference_identifier => '14' }
            r.a "TRACING_INT.ZIP", 'string', :value => '60606'
            r.a "TRACING_INT.ZIP4", 'string', :value => '4444'
          end
          @response_set.save!
          OperationalDataExtractor::Base.process(@response_set)
        end

        it "should prepopulate ADDRESS_1 if it exists" do
          init_instrument_and_response_set(nil,
               :create_tracing_module_survey_with_address_operational_data)
          TracingModule.new(@response_set).run
          assert_response_value(@response_set, 'ADDRESS_1', 'Address One')
        end

        it "should show prepopulate ADDRESS_2 if it exists" do
          init_instrument_and_response_set(nil,
               :create_tracing_module_survey_with_address_operational_data)
          TracingModule.new(@response_set).run
          assert_response_value(@response_set, 'ADDRESS_2', '123')
        end

        it "should show prepopulate UNIT if it exists" do
          init_instrument_and_response_set(nil,
               :create_tracing_module_survey_with_address_operational_data)
          TracingModule.new(@response_set).run
          assert_response_value(@response_set, 'UNIT', '321')
        end

        it "should show prepopulate CITY if it exists" do
          init_instrument_and_response_set(nil,
               :create_tracing_module_survey_with_address_operational_data)
          TracingModule.new(@response_set).run
          assert_response_value(@response_set, 'CITY', 'Chicago')
        end

        it "should show prepopulate STATE if it exists" do
          init_instrument_and_response_set(nil,
               :create_tracing_module_survey_with_address_operational_data)
          TracingModule.new(@response_set).run
          assert_response_value(@response_set, 'STATE', 'IL')
        end

        it "should show prepopulate ZIP if it exists" do
          init_instrument_and_response_set(nil,
               :create_tracing_module_survey_with_address_operational_data)
          TracingModule.new(@response_set).run
          assert_response_value(@response_set, 'ZIP', '60606')
        end

        it "should show prepopulate ZIP4 if it exists" do
          init_instrument_and_response_set(nil,
               :create_tracing_module_survey_with_address_operational_data)
          TracingModule.new(@response_set).run
          assert_response_value(@response_set, 'ZIP4', '4444')
        end
      end

      describe "asking address information" do

        it "should show if the contact is CATI and the event is birth" do
          event = Factory(:event, :event_type_code => Event.birth_code)
          run_populator(event, Instrument.cati)
          assert_response_value(@response_set,
                                "prepopulated_should_show_address_for_tracing",
                                "TRUE")
        end

        it "should NOT show if the contact is not CATI" do
          event = Factory(:event, :event_type_code => Event.birth_code)
          run_populator(event, Instrument.capi)
          assert_response_value(@response_set,
                                "prepopulated_should_show_address_for_tracing",
                                "FALSE")
        end

        it "should NOT show if the event is six_month_visit" do
          event = Factory(:event, :event_type_code => Event.six_month_visit_code)
          run_populator(event, Instrument.cati)
          assert_response_value(@response_set,
                                "prepopulated_should_show_address_for_tracing",
                                "FALSE")
        end

        describe "with a known address" do
          it "knows that the person has a primary address" do
            Factory(:address, :person => @person, :address_rank_code => 1)
            run_populator
            assert_response_value(@response_set,
                                  "prepopulated_is_address_provided", "TRUE")
          end
        end

        describe "without an address" do
          it "knows that the person does not have an address" do
            run_populator
            assert_response_value(@response_set,
                                  "prepopulated_is_address_provided", "FALSE")
          end
        end

      end

      describe "asking telephone information" do

        describe "with a known home phone" do
          it "knows that the person has a primary home phone" do
            Factory(:telephone, :person => @person, :phone_rank_code => 1, :phone_type_code => Telephone.home_phone_type.to_i)
            @person.primary_home_phone.should_not be_nil
            run_populator
            assert_response_value(@response_set, "prepopulated_is_home_phone_provided", "TRUE")
          end
        end

        describe "without a home phone" do
          it "knows that the person does not have a primary home phone" do
            @person.primary_home_phone.should be_nil
            run_populator
            assert_response_value(@response_set, "prepopulated_is_home_phone_provided", "FALSE")
          end
        end

        describe "with a known cell phone" do
          it "knows that the person has a primary cell phone" do
            Factory(:telephone, :person => @person, :phone_rank_code => 1, :phone_type_code => Telephone.cell_phone_type.to_i)
            @person.primary_cell_phone.should_not be_nil
            run_populator
            assert_response_value(@response_set, "prepopulated_is_valid_cell_phone_provided", "TRUE")
          end
        end

        describe "without a cell phone" do
          it "knows that the person does not have a primary cell phone" do
            @person.primary_cell_phone.should be_nil
            run_populator
            assert_response_value(@response_set, "prepopulated_is_valid_cell_phone_provided", "FALSE")
          end
        end

        describe "CELL_PHONE_2" do

          it "should not be provided if the question has not previously been answered" do
            run_populator
            assert_response_value(@response_set, "prepopulated_is_valid_cell_phone_2_provided", "FALSE")
          end

          it "should be provided if the question had previously been answered" do
            init_instrument_and_response_set
            take_survey(@survey, @response_set) do |r|
              r.dont_know "TRACING_INT.CELL_PHONE_2"
            end

            run_populator
            assert_response_value(@response_set, "prepopulated_is_valid_cell_phone_2_provided", "TRUE")
          end

        end

        describe "CELL_PHONE_3" do

          it "should not be provided if the question has not previously been answered" do
            run_populator
            assert_response_value(@response_set, "prepopulated_is_valid_cell_phone_3_provided", "FALSE")
          end

          it "should be provided if the question had previously been answered" do
            init_instrument_and_response_set
            take_survey(@survey, @response_set) do |r|
              r.dont_know "TRACING_INT.CELL_PHONE_3"
            end

            run_populator
            assert_response_value(@response_set, "prepopulated_is_valid_cell_phone_3_provided", "TRUE")
          end

        end

        describe "CELL_PHONE_4" do

          it "should not be provided if the question has not previously been answered" do
            run_populator
            assert_response_value(@response_set, "prepopulated_is_valid_cell_phone_4_provided", "FALSE")
          end

          it "should be provided if the question had previously been answered" do
            init_instrument_and_response_set
            take_survey(@survey, @response_set) do |r|
              r.dont_know "TRACING_INT.CELL_PHONE_4"
            end

            run_populator
            assert_response_value(@response_set, "prepopulated_is_valid_cell_phone_4_provided", "TRUE")
          end

        end

      end

      describe "asking email information" do

        it "should show email questions if EVENT_TYPE = BIRTH, PREGNANCY VISIT 1, PREGNANCY VISIT 2, 6 MONTH, OR 12 MONTH" do
          event = Factory(:event, :event_type_code => 18) # Birth
          run_populator(event)
          assert_response_value(@response_set, "prepopulated_should_show_email_for_tracing", "TRUE")
        end

        describe "with a known email" do
          it "knows that the person has a primary email" do
            Factory(:email, :person => @person, :email_rank_code => 1)
            @person.primary_email.should_not be_nil
            run_populator
            assert_response_value(@response_set, "prepopulated_is_valid_email_provided", "TRUE")
          end
        end

        describe "without an email" do
          it "knows that the person does not have a primary email" do
            @person.primary_email.should be_nil
            run_populator
            assert_response_value(@response_set, "prepopulated_is_valid_email_provided", "FALSE")
          end
        end

        describe "EMAIL_APPT" do

          it "should not be provided if the question has not previously been answered" do
            run_populator
            assert_response_value(@response_set, "prepopulated_is_valid_email_appt_provided", "FALSE")
          end

          it "should be provided if the question had previously been answered" do
            init_instrument_and_response_set
            take_survey(@survey, @response_set) do |r|
              r.dont_know "TRACING_INT.EMAIL_APPT"
            end

            run_populator
            assert_response_value(@response_set, "prepopulated_is_valid_email_appt_provided", "TRUE")
          end

        end

        describe "EMAIL_QUEST" do

          it "should not be provided if the question has not previously been answered" do
            run_populator
            assert_response_value(@response_set, "prepopulated_is_valid_email_questionnaire_provided", "FALSE")
          end

          it "should be provided if the question had previously been answered" do
            init_instrument_and_response_set
            take_survey(@survey, @response_set) do |r|
              r.dont_know "TRACING_INT.EMAIL_QUEST"
            end

            run_populator
            assert_response_value(@response_set, "prepopulated_is_valid_email_questionnaire_provided", "TRUE")
          end

        end

      end

      describe "contacts" do

        it "should show contact for tracing if EVENT_TYPE = PBS PARTICIPANT ELIGIBILITY SCREENING, PREGNANCY VISIT 1, PREGNANCY VISIT 2, 6 MONTH, OR 12 MONTH" do
          event = Factory(:event, :event_type_code => 13) # PV1
          run_populator(event)
          assert_response_value(@response_set, "prepopulated_should_show_contact_for_tracing", "TRUE")
        end

        it "should NOT show contact for tracing if EVENT_TYPE is not PBS PARTICIPANT ELIGIBILITY SCREENING, PREGNANCY VISIT 1, PREGNANCY VISIT 2, 6 MONTH, OR 12 MONTH" do
          event = Factory(:event, :event_type_code => 18) # Birth
          run_populator(event)
          assert_response_value(@response_set, "prepopulated_should_show_contact_for_tracing", "FALSE")
        end

        describe "previously provided" do

          it "should know that all contacts have been provided if three contacts have previously been given" do
            init_instrument_and_response_set
            friend = mock(NcsCode, :local_code => 6)
            mother = mock(NcsCode, :local_code => 1)
            sister = mock(NcsCode, :local_code => 2)
            take_survey(@survey, @response_set) do |r|
              r.a "TRACING_INT.CONTACT_RELATE_1", mother
              r.a "TRACING_INT.CONTACT_RELATE_2", sister
              r.a "TRACING_INT.CONTACT_RELATE_3", friend
            end

            run_populator
            assert_response_value(@response_set, "prepopulated_is_valid_contact_for_all_provided", "TRUE")
          end

          it "should know that NOT all contacts have been provided if no contacts have previously been given" do
            run_populator
            assert_response_value(@response_set, "prepopulated_is_valid_contact_for_all_provided", "FALSE")
          end

          it "should know that NOT all contacts have been provided if one contact has previously been given" do
            init_instrument_and_response_set
            mother = mock(NcsCode, :local_code => 1)
            take_survey(@survey, @response_set) do |r|
              r.a "TRACING_INT.CONTACT_RELATE_1", mother
            end
            run_populator
            assert_response_value(@response_set, "prepopulated_is_valid_contact_for_all_provided", "FALSE")
          end

          it "should know that NOT all contacts have been provided if two contacts have previously been given" do
            init_instrument_and_response_set
            friend = mock(NcsCode, :local_code => 6)
            mother = mock(NcsCode, :local_code => 1)
            take_survey(@survey, @response_set) do |r|
              r.a "TRACING_INT.CONTACT_RELATE_1", mother
              r.a "TRACING_INT.CONTACT_RELATE_2", friend
            end

            run_populator
            assert_response_value(@response_set, "prepopulated_is_valid_contact_for_all_provided", "FALSE")
          end
        end
      end

      describe "PREV_CITY" do

        it "should not be provided if the question has not previously been answered" do
          run_populator
          assert_response_value(@response_set, "prepopulated_is_prev_city_provided", "FALSE")
        end

        it "should be provided if the question had previously been answered" do
          init_instrument_and_response_set
          take_survey(@survey, @response_set) do |r|
            r.dont_know "TRACING_INT.PREV_CITY"
          end

          run_populator
          assert_response_value(@response_set, "prepopulated_is_prev_city_provided", "TRUE")
        end

      end

      describe "DR_LICENSE_NUM" do

        it "should not be provided if the question has not previously been answered" do
          run_populator
          assert_response_value(@response_set, "prepopulated_valid_driver_license_provided", "FALSE")
        end

        it "should be provided if the question had previously been answered" do
          init_instrument_and_response_set
          take_survey(@survey, @response_set) do |r|
            r.dont_know "TRACING_INT.DR_LICENSE_NUM"
          end

          run_populator
          assert_response_value(@response_set, "prepopulated_valid_driver_license_provided", "TRUE")
        end

      end

    end

    def assert_response_value(response_set, reference_identifier, value)
      response = response_set.responses.detect { |r| r.question.reference_identifier == reference_identifier }
      response.should_not be_nil
      response.to_s.should == value
    end

  end
end
