module Field
  module ProtocolEligibility

    def determine_eligibility
      psc = login_to_psc

      current_participants.each(&:reload)

      ineligible_participants, self.eligible_participants = current_participants.partition{ |p| p.ineligible? }
      
      ineligible_participants.map(&:person).compact.each(&:adjudicate_eligibility)
    end
  end
end
