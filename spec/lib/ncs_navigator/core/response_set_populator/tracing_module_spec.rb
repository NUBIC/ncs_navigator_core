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


      end



    end


    def assert_response_value(response_set, reference_identifier, value)
      response = response_set.responses.select { |r| r.question.reference_identifier == reference_identifier }.first
      response.should_not be_nil
      response.to_s.should == value
    end

  end

end