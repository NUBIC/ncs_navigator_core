module Field
  module ProtocolEligibility

    def determine_eligibility
      psc = login_to_psc

      current_participants.each(&:reload)

      ps = Participant.where(:id => current_participants.map(&:id)).includes(:participant_person_links => :person)
      ineligible, eligible = ps.partition(&:ineligible?)
      
      ineligible.map(&:person).each(&:adjudicate_eligibility)

      self.ineligible_participants = ineligible
    end
  end
end
