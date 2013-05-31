# -*- coding: utf-8 -*-

require 'spec_helper'

describe EligibilityAdjudicator do

  context "person having taken screener" do

    before :all do
      father =      Factory(:person)
      grandparent = Factory(:person)
      @participant = Factory(:participant)
      @person =      Factory(:person)
      provider = Factory(:provider)
      Factory(:person_provider_link, :person => @person, :provider => provider)
      Factory(:participant_person_link, :person => father, :participant=> @participant, :relationship_code => 4)
      Factory(:participant_person_link, :person => grandparent,:participant => @participant, :relationship_code => 10)
      Factory(:ppg_detail, :participant => @participant)
      consent = Factory(:participant_consent, :participant => @participant)
      Factory(:participant_consent_sample, :participant => @participant, :participant_consent => consent)
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
        Participant.any_instance.stub(:ineligible? => true)
        @adjudication = Participant.adjudicate_eligibility_and_disqualify_ineligible(@participant)
      end

      it "removes ppg_details from the participant" do
        PpgDetail.where(:participant_id => @response_set.participant).count.should == 0
      end

      it "deletes all participant_person_links for a participant" do
        ParticipantPersonLink.where(:participant_id => @response_set.participant).count.should == 0
      end

      it "sets the participant_id to nil for all events associated with the person" do
        Event.where(:participant_id => @response_set.participant_id).count.should be 0
      end

      it "does not delete the event records" do
        Event.exists?(@event.id).should be_true
      end

      it "sets the participant_id to nil for the response set" do
        ResponseSet.where(:participant_id => @response_set.participant_id).all? { |rs| rs.participant_id.nil? }.should be_true
      end

      it "creates a SamplePersonsIneligibility record" do
        SampledPersonsIneligibility.count.should == 1
      end

      it "deletes consent sample records" do
        ParticipantConsentSample.count.should == 0
      end

      it "deletes consent records" do
        ParticipantConsent.where(:participant_id => @response_set.participant_id).all.size.should == 0
      end


      it "deletes participant record" do
        Participant.count.should == 0
      end

      it "groups the person as ineligible" do
        @adjudication[:eligible].should be_empty
        @adjudication[:ineligible].should == [@participant]
      end
    end

    context "when eligible" do
      before do
        Participant.any_instance.stub(:eligible? => true)
        @adjudication = Participant.adjudicate_eligibility_and_disqualify_ineligible(@participant)
      end

      it "does not remove ppg_details from the participant" do
        PpgDetail.where(:participant_id => @response_set.participant).count.should == 1
      end

      it "does not delete participant_person_links for a participant" do
        ParticipantPersonLink.where(:participant_id => @response_set.participant.id).count.should == 3
      end

      it "does not disturb the participant association with events associated with the person" do
        Event.where(:participant_id => @response_set.participant_id).count.should be 1
      end

      it "does not set the participant_id to nil for the response set" do
        ResponseSet.find(@response_set.id).participant_id.should_not be_nil
      end

      it "does not create a SamplePersonsIneligibility record" do
        SampledPersonsIneligibility.count.should == 0
      end

      it "does not delete participant consent samples" do
        consents = ParticipantConsent.where(:participant_id => @participant.id).all
        sample_consents = consents.inject([]) { |sc, c| sc << ParticipantConsentSample.where(:participant_consent_id => c.id).all }
        sample_consents.flatten.size.should == 1
      end

      it "does not delete participant consents" do
        ParticipantConsent.where(:participant_id => @response_set.participant.id).count.should == 1
      end

      it "does not deletes participant record" do
        Participant.count.should be 1
      end

      it "adjudicates the person as eligible" do
        @adjudication[:eligible].should == [@participant]
        @adjudication[:ineligible].should be_empty
      end
    end

    context "when multiple participants" do
      let(:jeff) { Factory(:participant).tap{ |p| p.stub(:ineligible? => false) } }
      let(:greg) { Factory(:participant).tap{ |p| p.stub(:ineligible? => true) } }
      let(:steve) { Factory(:participant).tap{ |p| p.stub(:ineligible? => false) } }

      it "groups by eligiblity" do
        a = Participant.adjudicate_eligibility(jeff, steve, greg)
        a.should == {
          :eligible => [jeff, steve],
          :ineligible => [greg]
        }
      end
    end

  end
end
