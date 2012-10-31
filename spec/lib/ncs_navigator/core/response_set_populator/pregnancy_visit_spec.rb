# -*- coding: utf-8 -*-

require 'spec_helper'

module NcsNavigator::Core

  describe ResponseSetPopulator::PregnancyVisit do
    include SurveyCompletion

    def assert_response_value(response_set, reference_identifier, value)
      response = response_set.responses.select { |r| r.question.reference_identifier == reference_identifier }.first
      response.should_not be_nil
      response.to_s.should == value
    end

    context "with tracing instrument" do

      before(:each) do
        @person = Factory(:person)
        @participant = Factory(:participant)
        @ppl = Factory(:participant_person_link, :participant => @participant, :person => @person, :relationship_code => 1)

        @survey = create_pregnancy_visit_survey_with_prepopulated_fields
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
    end
  end
end