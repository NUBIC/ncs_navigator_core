# -*- coding: utf-8 -*-

require 'spec_helper'

describe EligibilityAdjudicator do

  context "person having taken screener" do

    before do
      father =      Factory(:person)
      grandparent = Factory(:person)
      @participant = Factory(:participant)
      @person =      Factory(:person)
      provider = Factory(:provider)
      Factory(:person_provider_link, :person => @person, :provider => provider)
      Factory(:participant_person_link, :person => father, :participant=> @participant, :relationship_code => 4)
      Factory(:participant_person_link, :person => grandparent,:participant => @participant, :relationship_code => 10)
      @person.participant = @participant
      @person.save!
      screener_survey = Factory(:survey, :title => "INS_QUE_PBSamplingScreen_INT_PBS_M3.0_V1.0")
      @response_set = Factory(:response_set, :survey => screener_survey, :person => @person, :participant => @participant)
      @another_response_set = Factory(:response_set, :survey => screener_survey, :person => @person, :participant => @participant)
      @and_another_response_set = Factory(:response_set, :survey => screener_survey, :person => @person, :participant => @participant)
      @event = Factory(:event, :participant => @response_set.participant)
    end

    context "when ineligible" do

      before do
        @participant.stub!(:ineligible? => true)
      end

      it "deletes all participant_person_links for a participant" do
        EligibilityAdjudicator.adjudicate_eligibility(@person)
        ParticipantPersonLink.where(:participant_id => @response_set.participant).count.should == 0
      end

      it "sets the participant_id to nil for all events associated with the person" do
        participant_id = @response_set.participant.id
        EligibilityAdjudicator.adjudicate_eligibility(@person)
        Event.where(:participant_id => participant_id).count.should be 0
      end

      it "does not delete the event records" do
        EligibilityAdjudicator.adjudicate_eligibility(@person)
        Event.exists?(@event.id).should be_true
      end

      it "sets the participant_id to nil for the response set" do
        participant_id = @response_set.participant.id
        EligibilityAdjudicator.adjudicate_eligibility(@person)
        ResponseSet.where(:participant_id => participant_id).all? { |rs| rs.participant_id.nil? }.should be_true
      end

      it "creates a SamplePersonsIneligibility record" do
        EligibilityAdjudicator.adjudicate_eligibility(@person)
        SampledPersonsIneligibility.count.should == 1
      end

      it "deletes participant record" do
        EligibilityAdjudicator.adjudicate_eligibility(@person)
        Participant.count.should == 0
      end
    end

    context "when eligible" do
      before do
        @participant.stub!(:eligible? => true)
      end

      it "does not delete participant_person_links for a participant" do
        EligibilityAdjudicator.adjudicate_eligibility(@person)
        ParticipantPersonLink.where(:participant_id => @response_set.participant.id).count.should == 3
      end

      it "does not disturb the participant association with events associated with the person" do
        participant_id = @response_set.participant.id
        EligibilityAdjudicator.adjudicate_eligibility(@person)
        Event.where(:participant_id => participant_id).count.should be 1
      end

      it "does not set the participant_id to nil for the response set" do
        EligibilityAdjudicator.adjudicate_eligibility(@person)
        ResponseSet.find(@response_set.id).participant_id.should_not be_nil
      end

      it "does not create a SamplePersonsIneligibility record" do
        EligibilityAdjudicator.adjudicate_eligibility(@person)
        SampledPersonsIneligibility.count.should == 0
      end

      it "does not deletes participant record" do
        EligibilityAdjudicator.adjudicate_eligibility(@person)
        Participant.count.should be 1
      end
    end

  end
end
