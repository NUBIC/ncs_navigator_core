# -*- coding: utf-8 -*-

require 'spec_helper'

module NcsNavigator::Core

  describe ResponseSetPopulator::Birth do

    context "with birth baby name instrument" do

      before(:each) do
        @person = Factory(:person)
        @participant = Factory(:participant)
        @ppl = Factory(:participant_person_link, :participant => @participant, :person => @person, :relationship_code => 1)

        @survey = create_birth_survey_with_prepopulated_mode_of_contact
        @response_set, @instrument = prepare_instrument(@person, @participant, @survey)
        # sanity check that there are no responses in response set
        @response_set.responses.should be_empty

      end

      describe "in person" do
        it "sets prepopulated_mode_of_contact to CAPI" do
          in_person = NcsCode.for_list_name_and_local_code('CONTACT_TYPE_CL1', 1)
          @contact = Factory(:contact, :contact_type => in_person)
          @contact_link = Factory(:contact_link, :person => @person, :contact => @contact)

          params = { :person => @person, :instrument => @instrument, :survey => @survey, :contact_link => @contact_link }
          rsp = ResponseSetPopulator::Base.new(params)
          rs = rsp.process
          rs.responses.should_not be_empty
          rs.should == @response_set
          rs.responses.first.question.reference_identifier.should == "prepopulated_mode_of_contact"
          rs.responses.first.to_s.should == "CAPI"
        end
      end

      describe "telephone" do
        it "sets prepopulated_mode_of_contact to CATI" do

          telephone = NcsCode.for_list_name_and_local_code('CONTACT_TYPE_CL1', 3)
          @contact = Factory(:contact, :contact_type => telephone)
          @contact_link = Factory(:contact_link, :person => @person, :contact => @contact)

          params = { :person => @person, :instrument => @instrument, :survey => @survey, :contact_link => @contact_link }
          rsp = ResponseSetPopulator::Base.new(params)
          rs = rsp.process
          rs.responses.should_not be_empty
          rs.should == @response_set
          rs.responses.first.question.reference_identifier.should == "prepopulated_mode_of_contact"
          rs.responses.first.to_s.should == "CATI"
        end
      end


    end

  end

end