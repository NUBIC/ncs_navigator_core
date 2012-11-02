# -*- coding: utf-8 -*-

require 'spec_helper'

module NcsNavigator::Core

  describe ResponseSetPopulator::Birth do
    include SurveyCompletion

    def assert_response_value(response_set, reference_identifier, value)
      response = response_set.responses.select { |r| r.question.reference_identifier == reference_identifier }.first
      response.should_not be_nil
      response.to_s.should == value
    end

    context "for responses from part one prepopulated in part two" do

      let(:person) { Factory(:person) }
      let(:survey_pt1) { create_birth_part_one_survey_with_prepopulated_fields_for_part_two }
      let(:survey_pt2) { create_birth_part_two_survey_with_prepopulated_fields_from_part_one }

      before(:each) do
        participant = Factory(:participant)
        participant.person = person
        participant.save!

        @response_set_pt1, @instrument_pt1 = prepare_instrument(person, participant, survey_pt1)
        @response_set_pt1.responses.should be_empty

        # Yes this should be the same instrument - bypassing the PSC reference connection for now
        @response_set_pt2, @instrument_pt2 = prepare_instrument(person, participant, survey_pt2)
        @response_set_pt2.responses.should be_empty
      end

      describe "BIRTH_DELIVER" do

        it "response should not exist if the question has not previously been answered" do
          params = { :person => person, :instrument => @instrument_pt2, :survey => survey_pt2 }
          responses = @response_set_pt2.responses.select { |r| r.question.reference_identifier == "prepopulated_birth_deliver_from_birth_visit_part_one" }
          responses.should be_empty
        end

        it "should be set to the response from part_one" do
          some_other_place = mock(NcsCode, :local_code => 'some_other_place')
          take_survey(survey_pt1, @response_set_pt1) do |a|
            a.choice "BIRTH_VISIT_3.BIRTH_DELIVER", some_other_place
          end

          assert_response_value(ResponseSetPopulator::Birth.new(person, @instrument_pt2, survey_pt2).populate,
            "prepopulated_birth_deliver_from_birth_visit_part_one", "SOME OTHER PLACE")
        end

      end

      describe "RELEASE" do

      end

      describe "MULTIPLE" do

      end

    end

    context "with birth baby name instrument" do

      let(:person) { Factory(:person) }
      let(:survey) { create_birth_survey_with_prepopulated_mode_of_contact }

      before(:each) do
        participant = Factory(:participant)
        participant.person = person
        participant.save!

        @response_set, @instrument = prepare_instrument(person, participant, survey)
        @response_set.responses.should be_empty
      end

      describe "in person" do
        it "sets prepopulated_mode_of_contact to CAPI" do
          in_person = NcsCode.for_list_name_and_local_code('CONTACT_TYPE_CL1', 1)
          contact = Factory(:contact, :contact_type => in_person)
          contact_link = Factory(:contact_link, :person => person, :contact => contact)

          rsp = ResponseSetPopulator::Birth.new(person, @instrument, survey, contact_link)
          rs = rsp.populate
          rs.responses.should_not be_empty
          rs.should == @response_set
          rs.responses.first.question.reference_identifier.should == "prepopulated_mode_of_contact"
          rs.responses.first.to_s.should == "CAPI"
        end
      end

      describe "telephone" do
        it "sets prepopulated_mode_of_contact to CATI" do

          telephone = NcsCode.for_list_name_and_local_code('CONTACT_TYPE_CL1', 3)
          contact = Factory(:contact, :contact_type => telephone)
          contact_link = Factory(:contact_link, :person => person, :contact => contact)

          params = { :person => person, :instrument => @instrument, :survey => survey, :contact_link => contact_link }
          rsp = ResponseSetPopulator::Birth.new(person, @instrument, survey, contact_link)
          rs = rsp.populate
          rs.responses.should_not be_empty
          rs.should == @response_set
          rs.responses.first.question.reference_identifier.should == "prepopulated_mode_of_contact"
          rs.responses.first.to_s.should == "CATI"
        end
      end

    end

  end

end