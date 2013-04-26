module EligibilityAdjudicator
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    # Elibilility can be adjudicated for one or more participants and then ineligible
    # participants are disqualified from the study. See usage below:
    # 
    # Participant.adjudicate_eligibility_and_disqualify_ineligible(
    # => participant1, participant2, participant3)
    #
    # @param [*Participant]
    # @return [Hash] Participants grouped by eligibility. 
    # => ex. {:eligible => [participant1, participant3], :ineligible => [participant2]}
    def adjudicate_eligibility_and_disqualify_ineligible(*participants)
      adjudicate_eligibility(*participants).tap do |adj|
        disqualify(*adj[:ineligible])
      end
    end

    def adjudicate_eligibility(*participants)
      ineligible, eligible = participants.partition{ |p| p.ineligible? }
      {:ineligible => ineligible, :eligible => eligible}
    end

    # DANGER: Only use if you want to remove participant(s) from the study. See usage below:
    # 
    # Participant.disqualify(participant1, participant2, participant3)
    def disqualify(*participants)
      found = Participant.where(:id => participants).
        includes(:events,
          :ppg_status_histories,
          :ppg_details,
          :response_sets,
          :low_intensity_state_transition_audits,
          :high_intensity_state_transition_audits,
          :participant_person_links => :person)

      ActiveRecord::Base.transaction do
        found.each do |p|
          creates_ineligibility_record(p.person)
          remove_ppg_details(p)
          delete_participant_person_links(p)
          disassociates_participant_from_all_events(p)
          disassociates_participant_from_response_sets(p)
          remove_participant(p)
        end
      end
    end

    private

    def creates_ineligibility_record(person)
      SampledPersonsIneligibility.create_from_person!(person)
    end

    def remove_ppg_details(participant)
      participant.ppg_status_histories.destroy_all
      participant.ppg_details.destroy_all
    end

    def delete_participant_person_links(participant)
      participant.participant_person_links.destroy_all
    end

    def disassociates_participant_from_all_events(participant)
      participant.events.update_all(:participant_id => nil)
    end

    def disassociates_participant_from_response_sets(participant)
      participant.response_sets.each { |rs| rs.update_attribute(:participant_id, nil) }
    end

    def remove_participant(participant)
      participant.low_intensity_state_transition_audits.destroy_all
      participant.high_intensity_state_transition_audits.destroy_all
      participant.destroy
    end
  end
end
