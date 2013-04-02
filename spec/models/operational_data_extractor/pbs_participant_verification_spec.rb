# -*- coding: utf-8 -*-

require 'spec_helper'

describe OperationalDataExtractor::PbsParticipantVerification do
  include SurveyCompletion
  include NcsNavigator::Core::Surveyor::SurveyTaker
  
  let(:survey) { create_pbs_part_verification_with_part_two_survey_for_m3_2 }

  context "child records" do
    before(:each) do
      @person = Factory(:person)
      @participant = Factory(:participant)
      @participant.person = @person

      @child_participant = @participant.create_child_person_and_participant!(
        {:first_name => "child_fname", :last_name => "child_lname"})

      @participant.participant_person_links.size.should == 1
      @participant.save!
    end

    it "updates the person (Child) record" do
      response_set, instrument = prepare_instrument(@person, @child_participant, survey)

      respond(response_set, survey) do |r|
        r.answer "CHILD_DOB", "date", :value => '01/01/2013'
      end
      response_set.save!
      response_set.responses.size.should == 1
      OperationalDataExtractor::PbsParticipantVerification.new(response_set).extract_data

      mother = Person.find(@person.id)
      participant = mother.participant
      participant.participant_person_links.size.should == 2
      participant.children.should_not be_nil

      child = participant.children.first
      child.should == @child_participant.person
      child.person_dob.should == '2013-01-01'

    end
  end
end