
class NcsNavigator::Core::ReconsentScheduler

  attr_accessor :participants
  attr_accessor :reschedule_date

  ##
  # Set the participants to schedule the Reconsent event on
  # the given date
  # @param[Array<Participant>]
  # @param[Date]
  # @param[PatientStudyCalendar]
  def initialize(participants, reschedule_date, psc)
    @participants = participants
    @reschedule_date = reschedule_date
    @psc = psc
  end

  ##
  # For each participant in @participants, schedule
  # the reconsent event on the @reschedule_date.
  # If a Participant cannot be scheduled, a message will be
  # logged and those Participant will be returned to the caller
  # @see Event.schedule_reconsent
  # @return[Array<Participant>] those Participants unable to be rescheduled
  def schedule
    participants_unable_to_be_scheduled = []
    @participants.each do |pt|

      msg = "Re-consent event scheduled for #{pt.p_id}."

      if pt.date_available_for_informed_consent_event?(@reschedule_date)
        resp = Event.schedule_reconsent(@psc, pt, @reschedule_date)
        unless resp.success?
          msg = "!!! Could not schedule informed consent for #{pt.p_id} !!!"
          participants_unable_to_be_scheduled << pt
        end
      else
        msg = "!!! Date [#{@reschedule_date}] unavailable for participant #{pt.p_id} !!!"
        participants_unable_to_be_scheduled << pt
      end
      $stderr.puts(msg)
      Rails.logger.info(msg)
    end
    participants_unable_to_be_scheduled
  end
end