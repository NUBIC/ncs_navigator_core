class MakingIneligible

  def self.make_ineligible(response_set)
    MakingIneligible.new(response_set).make_ineligible
  end

  def initialize(response_set)
    @person = response_set.person
    @participant = response_set.participant
    @response_set = response_set
  end

  def make_ineligible
    ActiveRecord::Base.transaction do
      creates_ineligibility_record(@person)
      delete_participant_person_links(@person, @participant)
      disassociates_participant_from_all_events(@participant)
      disassociates_participant_from_response_set(@response_set)
      remove_participant(@participant)
    end
  end

  def creates_ineligibility_record(person)
    SampledPersonsIneligibility.create_from_person!(person)
  end

  def delete_participant_person_links(person, participant)
    person.participant_person_links.destroy_all
    participant.participant_person_links.destroy_all
    ParticipantPersonLink.where(:participant_id => participant).all.each { |e| e.delete}
  end

  def disassociates_participant_from_all_events(participant)
    participant.events.destroy_all
  end

  def disassociates_participant_from_response_set(response_set)
    response_set.participant = nil
  end

  def remove_participant(participant)
    participant.low_intensity_state_transition_audits.destroy_all
    participant.high_intensity_state_transition_audits.destroy_all
    participant.destroy
  end
end
