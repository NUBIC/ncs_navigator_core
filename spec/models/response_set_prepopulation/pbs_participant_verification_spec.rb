# -*- coding: utf-8 -*-

require 'spec_helper'

require File.expand_path('../a_survey_title_acceptor', __FILE__)

module ResponseSetPrepopulation
  describe PbsParticipantVerification do
    include SurveyCompletion

    def assert_response_value(response_set, reference_identifier, value)
      response = response_set.responses.select { |r| r.question.reference_identifier == reference_identifier }.first
      response.should_not be_nil
      response.to_s.should == value
    end

    def run_populator
      PbsParticipantVerification.new(@response_set_pt2).run
    end

    context "for prepopulated P_TYPE 15 response in part two of M3.2" do
      let(:person) { Factory(:person) }
      let(:survey_pt2) { create_pbs_part_verification_with_part_two_survey_for_m3_2 }
      let(:participant) { Factory(:participant) }

      let(:version) { NcsNavigator::Core::Mdes::Version.new('3.2') }

      around do |example|
        begin
          old_version = NcsNavigatorCore.mdes_version
          NcsNavigatorCore.mdes_version = version
          NcsNavigator::Core::Mdes::CodeListLoader.new(
            :mdes_version => version.number).load_from_pg_dump
          example.call
        ensure
          NcsNavigatorCore.mdes_version = old_version
        end
      end

      describe "prepopulated_is_p_type_fifteen" do
        it "should be TRUE if participant is of p_code 15 type" do
          participant = Factory(:participant, :p_type_code => 15)
          participant.person = person
          participant.save!
          @response_set_pt2, @instrument_pt2 = prepare_instrument(person, participant, survey_pt2)
          run_populator
          assert_response_value(@response_set_pt2, "prepopulated_is_p_type_fifteen", "TRUE")
        end

        it "should be FALSE if participant is not of p_code 15 type" do
          participant.person = person
          participant.save!
          @response_set_pt2, @instrument_pt2 = prepare_instrument(person, participant, survey_pt2)
          run_populator
          assert_response_value(@response_set_pt2, "prepopulated_is_p_type_fifteen", "FALSE")
        end

        it "should be TRUE if participant is a child and participant's mother has p_code 15" do
          participant = Factory(:participant, :p_type_code => 15)
          person_child = Factory(:person)
          participant.participant_person_links << Factory(:participant_person_link, :person => person_child, :relationship_code => 8) # 8 Child
          participant.save!
          @response_set_pt2, @instrument_pt2 = prepare_instrument(person, participant, survey_pt2)
          run_populator
          assert_response_value(@response_set_pt2, "prepopulated_is_p_type_fifteen", "TRUE")
        end

        it "should be FALSE if participant is a child and participant's mother is not of p_code 15" do
          participant = Factory(:participant, :p_type_code => 10)
          person_child = Factory(:person)
          participant.participant_person_links << Factory(:participant_person_link, :person => person_child, :relationship_code => 8) # 8 Child
          participant.save!
          @response_set_pt2, @instrument_pt2 = prepare_instrument(person, participant, survey_pt2)
          run_populator
          assert_response_value(@response_set_pt2, "prepopulated_is_p_type_fifteen", "FALSE")
        end
      end
    end
  end
end
