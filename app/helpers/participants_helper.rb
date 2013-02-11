# -*- coding: utf-8 -*-


module ParticipantsHelper
  include ActionView::Helpers::UrlHelper

  def switch_arm_message(participant)
    msg = "Invite #{participant.person} to join High Intensity Arm"
    msg = "Move #{participant.person} from High Intensity to Low Intensity" if participant.high_intensity
    msg
  end

  def psc_assignment_path(assignment_id)
    "#{NcsNavigator.configuration.psc_uri}pages/subject?assignment=#{assignment_id}"
  end

  def consent_type_for(participant)
    participant.low_intensity? ? ParticipantConsent.low_intensity_consent_type_code : ParticipantConsent.general_consent_type_code
  end

  def determine_participant_consent_path(participant, contact_link, current_activity = false)
    consent = consent_type_for(participant)
    return nil if should_hide_consent?(consent.to_s)

    consent_type = NcsCode.for_attribute_name_and_local_code(:consent_type_code, consent.local_code)
    if participant.consented?(consent_type)
      cls = current_activity ? "star_link icon_link" : "edit_link icon_link"

      path = edit_participant_participant_consent_path(participant,
               participant.consent_for_type(consent_type),
               {:contact_link_id => contact_link.id})
    else
      cls = current_activity ? "star_link icon_link" : "add_link icon_link"

      path = new_participant_participant_consent_path(participant,
               {:contact_link_id => contact_link.id, :consent_type_code => consent.local_code})
    end
    link_to "Informed Consent", path, :class => cls
  end

  def should_hide_consent?(consent_type_text)
    consent_type_text.include?("collect") && !NcsNavigatorCore.expanded_phase_two?
  end

  def should_show_informed_consent_scheduling_form?(participant)
    participant.eligible? && !(participant.pending_events.first.try(:event_type_code) == Event.informed_consent_code)
  end

  def upcoming_events_for(person_or_participant)
    result = person_or_participant.upcoming_events.to_sentence
    result = remove_two_tier(result) unless recruitment_strategy.two_tier_knowledgable?
    result
  end

  def displayable_next_scheduled_event(event)
    result = event.to_s
    result = remove_two_tier(result) unless recruitment_strategy.two_tier_knowledgable?
    result
  end

  def remove_two_tier(txt)
    txt.to_s.gsub("#{PatientStudyCalendar::HIGH_INTENSITY}: ", '').gsub("#{PatientStudyCalendar::LOW_INTENSITY}: ", '')
  end
  private :remove_two_tier

  ##
  # Remove the 'Part One' or 'Part Two' (etc.) from the
  # activity name
  # @param activity [ScheduledActivity]
  # @return [String]
  def activity_name(activity)
    ret = activity.activity_name.to_s
    marker = "Part "
    if ret.include?(marker)
      ret = ret[0, ret.index(marker)]
    end
    ret.strip
  end

  def saq_confirmation_message(event)
    msg = event.closed? ? "This event is already closed.\n\n" : ""
    msg << "Would you like to record or add more information to the Self-Administered Questionnaire (SAQ)\n"
    msg << "for the #{event.event_type.to_s} Event?"
    msg
  end

  ##
  # "Originating Staff"
  # The name of the user that initiated the participant in the system
  # (e.g. the person who administered the eligibility screener).
  # @param[Participant]
  # @return[String]
  def participant_staff(participant)
    if participant && participant.completed_event?(screener_event)
      staff_name(originating_staff_id(participant))
    end
  end

  ##
  # The public identifier of the Staff member who
  # administered the screener instrument to the Participant.
  # @param[Participant]
  # @return[String]
  def originating_staff_id(participant)
    event = screener_event_for_participant(participant)
    instrument = instrument_for_screener_event(event)
    originating_staff(participant, event, instrument).try(:staff_id)
  end
  private :originating_staff_id

  ##
  # The ContactLink for the Participant, Event, and Instrument.
  # Used to get the staff_id for the screener event.
  # @param[Event]
  # @param[Instrument]
  # @return[ContactLink]
  def originating_staff(participant, event, instrument)
    participant.contact_links.where(:event_id => event,
        :instrument_id => instrument).select("staff_id").first
  end
  private :originating_staff

  ##
  # The screener event associated with the participant
  # @param[Participant]
  # @return[Event]
  def screener_event_for_participant(participant)
    event_codes = [
      Event.pbs_eligibility_screener_code,
      Event.pregnancy_screener_code
    ]
    Event.where(:event_type_code => event_codes, :participant_id => participant).select("id")
  end
  private :screener_event_for_participant

  ##
  # The instrument used during the screener event.
  # @param[Event]
  # @return[Instrument]
  def instrument_for_screener_event(event)
    instrument_codes = [
      Instrument.pbs_eligibility_screener_code,
      Instrument.pregnancy_screener_eh_code,
      Instrument.pregnancy_screener_pb_code,
      Instrument.pregnancy_screener_hilo_code,
    ]
    Instrument.where(:instrument_type_code => instrument_codes, :event_id => event).select("id")
  end
  private :instrument_for_screener_event

  ##
  # The screener event NcsCode based on Recruitment Strategy
  # @return[NcsCode]
  def screener_event
    NcsNavigatorCore.recruitment_strategy.pbs? ? NcsCode.pbs_eligibility_screener : NcsCode.pregnancy_screener
  end
  private :screener_event

  def psc_activity_options(activity)
    opts = ""
    Psc::ScheduledActivity::STATES.each do |a|
      opts << "<option value=\"#{a}\""
      opts << " selected=\"selected\"" if activity.current_state == a
      txt = a == Psc::ScheduledActivity::NA ? "N/A" : a.titleize
      opts << ">#{txt}</option>"
    end
    opts.html_safe
  end

end