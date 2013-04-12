module Field
  ##
  # Wrapper around Participant::adjudicate_participants_and_disqualify_ineligible, which
  # determines the eligibility of participants and disqualifies ineligible participants.
  #
  # Expects its host object to respond to:
  #
  # * {#login_to_psc} with a {PatientStudyCalendar} instance
  # * {#eligible_participants} with a list of {Participant} objects
  module ProtocolEligibility
    def determine_eligibility
      psc = login_to_psc

      # Ensure we have up-to-date data; we're entering this method out of a
      # lot of manipulations.
      current_participants.each(&:reload)
      
      # Adjudicate
      adj = Participant.adjudicate_eligibility_and_disqualify_ineligible(*current_participants)
      
      self.eligible_participants = adj[:eligible]
    end
  end
end
