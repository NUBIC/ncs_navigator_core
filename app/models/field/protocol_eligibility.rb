module Field
  module ProtocolEligibility

    def determine_eligibility
      psc = login_to_psc

      current_participants.each(&:reload)
      
      adj = EligibilityAdjudicator.adjudicate_eligibility_and_disqualify_ineligible(current_participants)
      
      self.eligible_participants = adj[:eligible]
    end
  end
end
