# -*- coding: utf-8 -*-

require 'spec_helper'

module NcsNavigator::Core

  describe ResponseSetPopulator::TracingModule do
    include SurveyCompletion

    context "with tracing instrument" do

      before(:each) do
        @person = Factory(:person)
        @participant = Factory(:participant)
        @ppl = Factory(:participant_person_link, :participant => @participant, :person => @person, :relationship_code => 1)

        @survey = create_tracing_survey_with_prepopulated_fields
        @response_set, @instrument = prepare_instrument(@person, @participant, @survey)
        # sanity check that there are no responses in response set
        @response_set.responses.should be_empty
      end

      describe "for a contact that is" do
        describe "in person" do
          it "prepopulated_mode_of_contact is set to CAPI" do
            in_person = NcsCode.for_list_name_and_local_code('CONTACT_TYPE_CL1', 1)
            @contact = Factory(:contact, :contact_type => in_person)
            @contact_link = Factory(:contact_link, :person => @person, :contact => @contact)

            params = { :person => @person, :instrument => @instrument, :survey => @survey, :contact_link => @contact_link }
            assert_response_value(ResponseSetPopulator::Base.new(params).process, "prepopulated_mode_of_contact", "CAPI")
          end
        end

        describe "via telephone" do
          it "prepopulated_mode_of_contact is set to CATI" do
            telephone = NcsCode.for_list_name_and_local_code('CONTACT_TYPE_CL1', 3)
            @contact = Factory(:contact, :contact_type => telephone)
            @contact_link = Factory(:contact_link, :person => @person, :contact => @contact)

            params = { :person => @person, :instrument => @instrument, :survey => @survey, :contact_link => @contact_link }
            assert_response_value(ResponseSetPopulator::Base.new(params).process, "prepopulated_mode_of_contact", "CATI")
          end
        end

      end

      describe "event type" do
        it "should be birth event if EVENT_TYPE = BIRTH" do
          event = Factory(:event, :event_type_code => 18) # Birth
          @contact_link = Factory(:contact_link, :person => @person, :contact => Factory(:contact), :event => event)

          params = { :person => @person, :instrument => @instrument, :survey => @survey, :contact_link => @contact_link }
          assert_response_value(ResponseSetPopulator::Base.new(params).process, "prepopulated_is_event_type_birth", "TRUE")
        end

        it "should NOT be birth event if EVENT_TYPE is not BIRTH" do
          event = Factory(:event, :event_type_code => 13) # NOT Birth
          @contact_link = Factory(:contact_link, :person => @person, :contact => Factory(:contact), :event => event)

          params = { :person => @person, :instrument => @instrument, :survey => @survey, :contact_link => @contact_link }
          assert_response_value(ResponseSetPopulator::Base.new(params).process, "prepopulated_is_event_type_birth", "FALSE")
        end

        it "should be PBS Eligibility Screener if EVENT_TYPE = PBS ELIGIBILITY SCREENING" do
          event = Factory(:event, :event_type_code => 34) # Eligibility Screener
          @contact_link = Factory(:contact_link, :person => @person, :contact => Factory(:contact), :event => event)

          params = { :person => @person, :instrument => @instrument, :survey => @survey, :contact_link => @contact_link }
          assert_response_value(ResponseSetPopulator::Base.new(params).process, "prepopulated_is_event_type_pbs_participant_eligibility_screening", "TRUE")

        end

        it "should NOT be PBS Eligibility Screener if EVENT_TYPE is not PBS ELIGIBILITY SCREENING" do
          event = Factory(:event, :event_type_code => 13) # NOT Eligibility Screener
          @contact_link = Factory(:contact_link, :person => @person, :contact => Factory(:contact), :event => event)

          params = { :person => @person, :instrument => @instrument, :survey => @survey, :contact_link => @contact_link }
          assert_response_value(ResponseSetPopulator::Base.new(params).process, "prepopulated_is_event_type_pbs_participant_eligibility_screening", "FALSE")
        end
      end

      describe "asking address information" do

        it "should show if the contact is CATI and the event is post-natal" do
          event = Factory(:event, :event_type_code => 18) # Birth is also post-natal
          telephone = NcsCode.for_list_name_and_local_code('CONTACT_TYPE_CL1', 3)
          @contact = Factory(:contact, :contact_type => telephone)
          @contact_link = Factory(:contact_link, :person => @person, :contact => @contact, :event => event)

          params = { :person => @person, :instrument => @instrument, :survey => @survey, :contact_link => @contact_link }
          assert_response_value(ResponseSetPopulator::Base.new(params).process, "prepopulated_should_show_address_for_tracing", "TRUE")
        end

        it "should NOT show if the contact is not CATI" do
          event = Factory(:event, :event_type_code => 18) # Birth is also post-natal
          in_person = NcsCode.for_list_name_and_local_code('CONTACT_TYPE_CL1', 1)
          @contact = Factory(:contact, :contact_type => in_person)
          @contact_link = Factory(:contact_link, :person => @person, :contact => @contact, :event => event)

          params = { :person => @person, :instrument => @instrument, :survey => @survey, :contact_link => @contact_link }
          assert_response_value(ResponseSetPopulator::Base.new(params).process, "prepopulated_should_show_address_for_tracing", "FALSE")
        end

        it "should NOT show if the event is pre-natal" do
          event = Factory(:event, :event_type_code => 34) # Eligibility Screener is pre-natal
          telephone = NcsCode.for_list_name_and_local_code('CONTACT_TYPE_CL1', 3)
          @contact = Factory(:contact, :contact_type => telephone)
          @contact_link = Factory(:contact_link, :person => @person, :contact => @contact, :event => event)

          params = { :person => @person, :instrument => @instrument, :survey => @survey, :contact_link => @contact_link }
          assert_response_value(ResponseSetPopulator::Base.new(params).process, "prepopulated_should_show_address_for_tracing", "FALSE")
        end

        describe "with a known address" do
          it "knows that the person has a primary address" do
            Factory(:address, :person => @person, :address_rank_code => 1)
            params = { :person => @person, :instrument => @instrument, :survey => @survey }
            assert_response_value(ResponseSetPopulator::Base.new(params).process, "prepopulated_is_address_provided", "TRUE")
          end
        end

        describe "without an address" do
          it "knows that the person does not have an address" do
            params = { :person => @person, :instrument => @instrument, :survey => @survey }
            assert_response_value(ResponseSetPopulator::Base.new(params).process, "prepopulated_is_address_provided", "FALSE")
          end
        end

      end

      describe "asking telephone information" do

        describe "with a known home phone" do
          it "knows that the person has a primary home phone" do
            Factory(:telephone, :person => @person, :phone_rank_code => 1, :phone_type_code => Telephone.home_phone_type.to_i)
            @person.primary_home_phone.should_not be_nil
            params = { :person => @person, :instrument => @instrument, :survey => @survey }
            assert_response_value(ResponseSetPopulator::Base.new(params).process, "prepopulated_is_home_phone_provided", "TRUE")
          end
        end

        describe "without a home phone" do
          it "knows that the person does not have a primary home phone" do
            @person.primary_home_phone.should be_nil
            params = { :person => @person, :instrument => @instrument, :survey => @survey }
            assert_response_value(ResponseSetPopulator::Base.new(params).process, "prepopulated_is_home_phone_provided", "FALSE")
          end
        end

        describe "with a known cell phone" do
          it "knows that the person has a primary cell phone" do
            Factory(:telephone, :person => @person, :phone_rank_code => 1, :phone_type_code => Telephone.cell_phone_type.to_i)
            @person.primary_cell_phone.should_not be_nil
            params = { :person => @person, :instrument => @instrument, :survey => @survey }
            assert_response_value(ResponseSetPopulator::Base.new(params).process, "prepopulated_is_valid_cell_phone_provided", "TRUE")
          end
        end

        describe "without a cell phone" do
          it "knows that the person does not have a primary cell phone" do
            @person.primary_cell_phone.should be_nil
            params = { :person => @person, :instrument => @instrument, :survey => @survey }
            assert_response_value(ResponseSetPopulator::Base.new(params).process, "prepopulated_is_valid_cell_phone_provided", "FALSE")
          end
        end

        describe "CELL_PHONE_2" do

          it "should not be provided if the question has not previously been answered" do
            params = { :person => @person, :instrument => @instrument, :survey => @survey }
            assert_response_value(ResponseSetPopulator::Base.new(params).process, "prepopulated_is_valid_cell_phone_2_provided", "FALSE")
          end

          it "should be provided if the question had previously been answered" do

            take_survey(@survey, @response_set) do |a|
              a.dont_know "TRACING_INT.CELL_PHONE_2"
            end

            params = { :person => @person, :instrument => @instrument, :survey => @survey }
            assert_response_value(ResponseSetPopulator::Base.new(params).process, "prepopulated_is_valid_cell_phone_2_provided", "TRUE")
          end

        end

        describe "CELL_PHONE_3" do

          it "should not be provided if the question has not previously been answered" do
            params = { :person => @person, :instrument => @instrument, :survey => @survey }
            assert_response_value(ResponseSetPopulator::Base.new(params).process, "prepopulated_is_valid_cell_phone_3_provided", "FALSE")
          end

          it "should be provided if the question had previously been answered" do

            take_survey(@survey, @response_set) do |a|
              a.dont_know "TRACING_INT.CELL_PHONE_3"
            end

            params = { :person => @person, :instrument => @instrument, :survey => @survey }
            assert_response_value(ResponseSetPopulator::Base.new(params).process, "prepopulated_is_valid_cell_phone_3_provided", "TRUE")
          end

        end

        describe "CELL_PHONE_4" do

          it "should not be provided if the question has not previously been answered" do
            params = { :person => @person, :instrument => @instrument, :survey => @survey }
            assert_response_value(ResponseSetPopulator::Base.new(params).process, "prepopulated_is_valid_cell_phone_4_provided", "FALSE")
          end

          it "should be provided if the question had previously been answered" do

            take_survey(@survey, @response_set) do |a|
              a.dont_know "TRACING_INT.CELL_PHONE_4"
            end

            params = { :person => @person, :instrument => @instrument, :survey => @survey }
            assert_response_value(ResponseSetPopulator::Base.new(params).process, "prepopulated_is_valid_cell_phone_4_provided", "TRUE")
          end

        end

      end

      describe "asking email information" do

        it "should show email questions if EVENT_TYPE = BIRTH, PREGNANCY VISIT 1, PREGNANCY VISIT 2, 6 MONTH, OR 12 MONTH" do
          event = Factory(:event, :event_type_code => 18) # Birth
          @contact_link = Factory(:contact_link, :person => @person, :contact => Factory(:contact), :event => event)

          params = { :person => @person, :instrument => @instrument, :survey => @survey, :contact_link => @contact_link }
          assert_response_value(ResponseSetPopulator::Base.new(params).process, "prepopulated_should_show_email_for_tracing", "TRUE")
        end

        describe "with a known email" do
          it "knows that the person has a primary email" do
            Factory(:email, :person => @person, :email_rank_code => 1)
            @person.primary_email.should_not be_nil
            params = { :person => @person, :instrument => @instrument, :survey => @survey }
            assert_response_value(ResponseSetPopulator::Base.new(params).process, "prepopulated_is_valid_email_provided", "TRUE")
          end
        end

        describe "without an email" do
          it "knows that the person does not have a primary email" do
            @person.primary_email.should be_nil
            params = { :person => @person, :instrument => @instrument, :survey => @survey }
            assert_response_value(ResponseSetPopulator::Base.new(params).process, "prepopulated_is_valid_email_provided", "FALSE")
          end
        end

        describe "EMAIL_APPT" do

          it "should not be provided if the question has not previously been answered" do
            params = { :person => @person, :instrument => @instrument, :survey => @survey }
            assert_response_value(ResponseSetPopulator::Base.new(params).process, "prepopulated_is_valid_email_appt_provided", "FALSE")
          end

          it "should be provided if the question had previously been answered" do

            take_survey(@survey, @response_set) do |a|
              a.dont_know "TRACING_INT.EMAIL_APPT"
            end

            params = { :person => @person, :instrument => @instrument, :survey => @survey }
            assert_response_value(ResponseSetPopulator::Base.new(params).process, "prepopulated_is_valid_email_appt_provided", "TRUE")
          end

        end

        describe "EMAIL_QUEST" do

          it "should not be provided if the question has not previously been answered" do
            params = { :person => @person, :instrument => @instrument, :survey => @survey }
            assert_response_value(ResponseSetPopulator::Base.new(params).process, "prepopulated_is_valid_email_questionnaire_provided", "FALSE")
          end

          it "should be provided if the question had previously been answered" do

            take_survey(@survey, @response_set) do |a|
              a.dont_know "TRACING_INT.EMAIL_QUEST"
            end

            params = { :person => @person, :instrument => @instrument, :survey => @survey }
            assert_response_value(ResponseSetPopulator::Base.new(params).process, "prepopulated_is_valid_email_questionnaire_provided", "TRUE")
          end

        end


      end

      describe "contacts" do

        it "should show contact for tracing if EVENT_TYPE = PBS PARTICIPANT ELIGIBILITY SCREENING, PREGNANCY VISIT 1, PREGNANCY VISIT 2, 6 MONTH, OR 12 MONTH" do
          event = Factory(:event, :event_type_code => 13) # PV1
          @contact_link = Factory(:contact_link, :person => @person, :contact => Factory(:contact), :event => event)

          params = { :person => @person, :instrument => @instrument, :survey => @survey, :contact_link => @contact_link }
          assert_response_value(ResponseSetPopulator::Base.new(params).process, "prepopulated_should_show_contact_for_tracing", "TRUE")

        end

        it "should NOT show contact for tracing if EVENT_TYPE is not PBS PARTICIPANT ELIGIBILITY SCREENING, PREGNANCY VISIT 1, PREGNANCY VISIT 2, 6 MONTH, OR 12 MONTH" do
          event = Factory(:event, :event_type_code => 18) # Birth
          @contact_link = Factory(:contact_link, :person => @person, :contact => Factory(:contact), :event => event)

          params = { :person => @person, :instrument => @instrument, :survey => @survey, :contact_link => @contact_link }
          assert_response_value(ResponseSetPopulator::Base.new(params).process, "prepopulated_should_show_contact_for_tracing", "FALSE")
        end


        describe "previously provided" do

          it "should know that all contacts have been provided if three contacts have previously been given" do

            friend = mock(NcsCode, :local_code => 6)
            mother = mock(NcsCode, :local_code => 1)
            sister = mock(NcsCode, :local_code => 2)
            take_survey(@survey, @response_set) do |a|
              a.choice "TRACING_INT.CONTACT_RELATE_1", mother
              a.choice "TRACING_INT.CONTACT_RELATE_2", sister
              a.choice "TRACING_INT.CONTACT_RELATE_3", friend
            end


            params = { :person => @person, :instrument => @instrument, :survey => @survey }
            assert_response_value(ResponseSetPopulator::Base.new(params).process, "prepopulated_is_valid_contact_for_all_provided", "TRUE")
          end

          it "should know that NOT all contacts have been provided if no contacts have previously been given" do
            params = { :person => @person, :instrument => @instrument, :survey => @survey }
            assert_response_value(ResponseSetPopulator::Base.new(params).process, "prepopulated_is_valid_contact_for_all_provided", "FALSE")
          end

          it "should know that NOT all contacts have been provided if one contact has previously been given" do

            mother = mock(NcsCode, :local_code => 1)
            take_survey(@survey, @response_set) do |a|
              a.choice "TRACING_INT.CONTACT_RELATE_1", mother
            end
            params = { :person => @person, :instrument => @instrument, :survey => @survey }
            assert_response_value(ResponseSetPopulator::Base.new(params).process, "prepopulated_is_valid_contact_for_all_provided", "FALSE")
          end

          it "should know that NOT all contacts have been provided if two contacts have previously been given" do

            friend = mock(NcsCode, :local_code => 6)
            mother = mock(NcsCode, :local_code => 1)
            take_survey(@survey, @response_set) do |a|
              a.choice "TRACING_INT.CONTACT_RELATE_1", mother
              a.choice "TRACING_INT.CONTACT_RELATE_2", friend
            end

            params = { :person => @person, :instrument => @instrument, :survey => @survey }
            assert_response_value(ResponseSetPopulator::Base.new(params).process, "prepopulated_is_valid_contact_for_all_provided", "FALSE")
          end
        end
      end

      describe "PREV_CITY" do

        it "should not be provided if the question has not previously been answered" do
          params = { :person => @person, :instrument => @instrument, :survey => @survey }
          assert_response_value(ResponseSetPopulator::Base.new(params).process, "prepopulated_is_prev_city_provided", "FALSE")
        end

        it "should be provided if the question had previously been answered" do

          take_survey(@survey, @response_set) do |a|
            a.dont_know "TRACING_INT.PREV_CITY"
          end

          params = { :person => @person, :instrument => @instrument, :survey => @survey }
          assert_response_value(ResponseSetPopulator::Base.new(params).process, "prepopulated_is_prev_city_provided", "TRUE")
        end

      end

      describe "DR_LICENSE_NUM" do

        it "should not be provided if the question has not previously been answered" do
          params = { :person => @person, :instrument => @instrument, :survey => @survey }
          assert_response_value(ResponseSetPopulator::Base.new(params).process, "prepopulated_valid_driver_license_provided", "FALSE")
        end

        it "should be provided if the question had previously been answered" do

          take_survey(@survey, @response_set) do |a|
            a.dont_know "TRACING_INT.DR_LICENSE_NUM"
          end

          params = { :person => @person, :instrument => @instrument, :survey => @survey }
          assert_response_value(ResponseSetPopulator::Base.new(params).process, "prepopulated_valid_driver_license_provided", "TRUE")
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