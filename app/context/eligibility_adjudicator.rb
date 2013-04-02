class EligibilityAdjudicator

  def initialize(person)
    @person = person
    @participant = person.participant
  end

  def self.adjudicate_eligibility(person)
    me = EligibilityAdjudicator.new(person)
    me.make_ineligible if person.participant.try(:ineligible?)
  end

  def make_ineligible
    ActiveRecord::Base.transaction do
      creates_ineligibility_record(@person)
      remove_ppg_details(@participant)
      delete_participant_person_links(@participant)
      disassociates_participant_from_all_events(@participant)
      disassociates_participant_from_response_sets(@participant)
      remove_participant(@participant)
    end
  end

  private

  def creates_ineligibility_record(person)
    SampledPersonsIneligibility.create_from_person!(person)
  end

  def remove_ppg_details(participant)
    PpgStatusHistory.where(:participant_id => participant).destroy_all
    PpgDetail.where(:participant_id => participant).destroy_all
  end

  def delete_participant_person_links(participant)
    ParticipantPersonLink.where(:participant_id => participant).destroy_all
  end

  def disassociates_participant_from_all_events(participant)
    participant.events.update_all(:participant_id => nil)
  end

  def disassociates_participant_from_response_sets(participant)
    ResponseSet.where(:participant_id => participant.id).each { |rs| rs.update_attribute(:participant_id, nil) }
  end

  def remove_participant(participant)
    participant.low_intensity_state_transition_audits.destroy_all
    participant.high_intensity_state_transition_audits.destroy_all
    participant.destroy
  end
end
