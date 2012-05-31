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

  def determine_participant_consent_path(consent_type_code, consent_type_text, participant, contact_link)
    return nil if should_hide_consent?(consent_type_text)
    consent_type = NcsCode.for_attribute_name_and_local_code(:consent_type_code, consent_type_code)
    if participant.consented?(consent_type)
      consent = participant.consent_for_type(consent_type)
      link_to consent_type_text, edit_participant_consent_path(consent, :contact_link_id => contact_link.id), :class => "edit_link icon_link"
    else
      link_to consent_type_text, new_participant_consent_path(:participant_id => participant.id, :contact_link_id => contact_link.id, :consent_type_code => consent_type_code), :class => "add_link icon_link"
    end
  end

  def should_hide_consent?(consent_type_text)
    consent_type_text.include?("collect") && !NcsNavigatorCore.expanded_phase_two?
  end

  def displayable_event_name(event, participant)
    event_name = event.to_s
    if recruitment_strategy.two_tier_knowledgable?
      epoch = participant.high_intensity? ? PatientStudyCalendar::HIGH_INTENSITY : PatientStudyCalendar::LOW_INTENSITY
      event_name = "#{epoch}: #{event.to_s}"
    end
    event_name
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