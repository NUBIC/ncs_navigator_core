# -*- coding: utf-8 -*-

require 'spec_helper'

describe MakingIneligible do
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
    @event2 = Factory(:event, :participant_id => @response_set.participant.id)
  end

  it "deletes all participant_person_links for a participant" do
    MakingIneligible.make_ineligible(@response_set)
    ParticipantPersonLink.where(:participant_id => @response_set.participant).all.size.should be 0
  end

  it "sets the participant_id to nil for all events associated with the person" do
    participant_id =  @response_set.participant.id
    MakingIneligible.make_ineligible(@response_set)
    Event.where(:participant_id => participant_id).count.should be 0
  end

  it "does not delete the event records" do
    participant_id =  @response_set.participant.id
    MakingIneligible.make_ineligible(@response_set)
    @event1.should_not be_nil
  end

  it "sets the participant_id to nil for the response set" do
    MakingIneligible.make_ineligible(@response_set)
    @response_set.participant.should be_nil
  end

  it "calls #create_from_particpant! from the SampledPersonsIneligibility class" do
    SampledPersonsIneligibility.should_receive(:create_from_person!)
                               .with(@response_set.person)
                               .and_return(an_instance_of(SampledPersonsIneligibility))
    MakingIneligible.make_ineligible(@response_set)
  end

  it "creates an ineligibility record" do
    MakingIneligible.make_ineligible(@response_set)
    SampledPersonsIneligibility.count.should be 1
  end

  it "deletes participant record" do
    MakingIneligible.make_ineligible(@response_set)
    Participant.count.should be 0
  end
end
