class MakeIneligible

  def self.run(response_set)
    MakeIneligible.new(response_set).make_ineligible
  end

  def initialize(response_set)
    @person = response_set.person
    @participant = response_set.participant
    @response_set = response_set
  end

  def make_ineligible
    ActiveRecord::Base.transaction do
      creates_ineligibility_record(@person)
      delete_participant_person_links(@participant)
      disassociates_participant_from_all_events(@participant)
      disassociates_participant_from_response_set(@response_set)
      remove_participant(@participant)
    end
  end

  def creates_ineligibility_record(person)
    SampledPersonsIneligibility.create_from_person!(person)
  end

  def delete_participant_person_links(participant)
    ParticipantPersonLink.where(:participant_id => participant.id).destroy_all
  end

  def disassociates_participant_from_all_events(participant)
    participant.events.update_all(:participant_id => nil)
  end

  def disassociates_participant_from_response_set(response_set)
    ResponseSet.find(response_set.id).update_attribute(:participant_id, nil)
  end

  def remove_participant(participant)
    participant.low_intensity_state_transition_audits.destroy_all
    participant.high_intensity_state_transition_audits.destroy_all
    participant.destroy
  end
end
