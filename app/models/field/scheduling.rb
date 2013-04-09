module Field
  ##
  # Methods for scheduling participants.
  #
  # Expects its host object to respond to:
  #
  # * {#login_to_psc} with a {PatientStudyCalendar} instance
  # * {#current_participants} with a list of {Participant} objects
  module Scheduling
    include PscSync

    def advance_participant_schedules
      psc = login_to_psc

      # Ensure we have up-to-date data; we're entering this method out of a
      # lot of manipulations.
      eligible_participants.each(&:reload)

      # Advance.
      eligible_participants.each { |p| p.advance(psc) }
    end
  end
end
