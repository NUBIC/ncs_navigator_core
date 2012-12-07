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
end