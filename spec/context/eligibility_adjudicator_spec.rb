# -*- coding: utf-8 -*-

require 'spec_helper'

describe EligibilityAdjudicator do

  context "person having taken screener" do

    before do
      father =      Factory(:person)
      grandparent = Factory(:person)
      @participant = Factory(:participant)
      person =      Factory(:person)
      provider = Factory(:provider)
      Factory(:person_provider_link, :person => person, :provider => provider)
      Factory(:participant_person_link, :person => father, :participant=> @participant, :relationship_code => 4)
      Factory(:participant_person_link, :person => grandparent,:participant => @participant, :relationship_code => 10)
      person.participant = @participant
      person.save!
      screener_survey = Factory(:survey, :title => "INS_QUE_PBSamplingScreen_INT_PBS_M3.0_V1.0")
      @response_set = Factory(:response_set, :survey => screener_survey, :person => person, :participant => @participant)
      @event = Factory(:event, :participant => @response_set.participant)
    end

    context "when ineligible" do

      before do
        @participant.stub!(:eligible? => false)
      end

      it "deletes all participant_person_links for a participant" do
        EligibilityAdjudicator.adjudicate_eligibility(@response_set)
        ParticipantPersonLink.where(:participant_id => @response_set.participant).count.should == 0
      end

      it "sets the participant_id to nil for all events associated with the person" do
        participant_id = @response_set.participant.id
        EligibilityAdjudicator.adjudicate_eligibility(@response_set)
        Event.where(:participant_id => participant_id).count.should be 0
      end

      it "does not delete the event records" do
        participant_id = @response_set.participant.id
        EligibilityAdjudicator.adjudicate_eligibility(@response_set)
        Event.exists?(@event.id).should be_true
      end

      it "sets the participant_id to nil for the response set" do
        EligibilityAdjudicator.adjudicate_eligibility(@response_set)
        ResponseSet.find(@response_set.id).participant_id.should be_nil
      end

      it "creates a SamplePersonsIneligibility record" do
        EligibilityAdjudicator.adjudicate_eligibility(@response_set)
        SampledPersonsIneligibility.count.should == 1
      end

      it "deletes participant record" do
        EligibilityAdjudicator.adjudicate_eligibility(@response_set)
        Participant.count.should == 0
      end
    end

    context "when eligible" do
      before do
        @participant.stub!(:eligible? => true)
      end

      it "does not delete participant_person_links for a participant" do
        EligibilityAdjudicator.adjudicate_eligibility(@response_set)
        ParticipantPersonLink.where(:participant_id => @response_set.participant.id).count.should == 3
      end

      it "does not disturb the participant association with events associated with the person" do
        participant_id = @response_set.participant.id
        EligibilityAdjudicator.adjudicate_eligibility(@response_set)
        Event.where(:participant_id => participant_id).count.should be 1
      end

      it "does not set the participant_id to nil for the response set" do
        EligibilityAdjudicator.adjudicate_eligibility(@response_set)
        ResponseSet.find(@response_set.id).participant_id.should_not be_nil
      end

      it "does not create a SamplePersonsIneligibility record" do
        EligibilityAdjudicator.adjudicate_eligibility(@response_set)
        SampledPersonsIneligibility.count.should == 0
      end

      it "does not deletes participant record" do
        EligibilityAdjudicator.adjudicate_eligibility(@response_set)
        Participant.count.should be 1
      end
    end

  end

  describe "#person_taking_screener_ineligible?" do

    before do
      screener_survey     = Factory(:survey, :title => "INS_QUE_PBSamplingScreen_INT_PBS_M3.0_V1.0")
      non_screener_survey = Factory(:survey, :title => "INS_QUE_Birth_INT_EHPBHIPBS_M3.0_V3.0_PART_TWO")
      ineligible_participant = Factory(:participant)
      eligible_participant   = Factory(:participant)
      ineligible_participant.stub!(:eligible? => false)
      eligible_participant.stub!(:eligible? => true)
      @screener_and_ineligible_person_response_set     = Factory(:response_set, :survey_id => screener_survey.id,     :participant => ineligible_participant)
      @non_screener_and_ineligible_person_response_set = Factory(:response_set, :survey_id => non_screener_survey.id, :participant => ineligible_participant)
      @screener_and_eligible_person_response_set       = Factory(:response_set, :survey_id => screener_survey.id,     :participant => eligible_participant)
      @non_screener_and_eligible_person_response_set   = Factory(:response_set, :survey_id => non_screener_survey.id, :participant => eligible_participant)
    end

    context "survey is screener" do
      it "returns false when person is eligible" do
        EligibilityAdjudicator.new(@screener_and_eligible_person_response_set).person_taking_screener_ineligible?.should be_false
      end

      it "returns true when person is not eligible" do
        EligibilityAdjudicator.new(@screener_and_ineligible_person_response_set).person_taking_screener_ineligible?.should be_true
      end
    end

    context "survey is not screener" do
      it "returns false when person is eligible" do
        EligibilityAdjudicator.new(@non_screener_and_eligible_person_response_set).person_taking_screener_ineligible?.should be_false
      end

      it "returns false when person is not eligible" do
        EligibilityAdjudicator.new(@non_screener_and_ineligible_person_response_set).person_taking_screener_ineligible?.should be_false
      end
    end
  end
end
