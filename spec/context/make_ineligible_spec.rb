# -*- coding: utf-8 -*-

require 'spec_helper'

describe MakeIneligible do
  before do
    person =      Factory(:person)
    father =      Factory(:person)
    grandparent = Factory(:person)
    participant = Factory(:participant)
    provider = Factory(:provider)
    Factory(:person_provider_link, :person_id => person.id, :provider_id => provider.id)
    Factory(:participant_person_link, :person_id => father.id, :participant_id => participant.id, :relationship_code => 4)
    Factory(:participant_person_link, :person_id => grandparent.id,:participant_id => participant.id, :relationship_code => 10)
    participant.person= person
    participant.save!
    @response_set = Factory(:response_set, :user_id => person.id, :participant_id => participant.id)
    @event1 = Factory(:event, :participant_id => @response_set.participant.id)
  end

  it "deletes all participant_person_links for a participant" do
    MakeIneligible.run(@response_set)
    ParticipantPersonLink.where(:participant_id => @response_set.participant).count.should == 0
  end

  it "sets the participant_id to nil for all events associated with the person" do
    participant_id = @response_set.participant.id
    MakeIneligible.run(@response_set)
    Event.where(:participant_id => participant_id).count.should be 0
  end

  it "does not delete the event records" do
    participant_id = @response_set.participant.id
    MakeIneligible.run(@response_set)
    Event.exists?(@event1.id).should be_true
  end

  it "sets the participant_id to nil for the response set" do
    MakeIneligible.run(@response_set)
    ResponseSet.find(@response_set.id).participant_id.should be_nil
  end

  it "creates a SamplePersonsIneligibility record" do
    MakeIneligible.run(@response_set)
    SampledPersonsIneligibility.count.should == 1
  end

  it "creates an ineligibility record" do
    MakeIneligible.run(@response_set)
    SampledPersonsIneligibility.count.should == 1
  end

  it "deletes participant record" do
    MakeIneligible.run(@response_set)
    Participant.count.should be 0
  end
end
