# -*- coding: utf-8 -*-

module ContactLinksHelper

  ##
  # Return true if the given survey title is in the list
  # of instrument_survey_titles for the event.
  #
  # @see InstrumentOwner#instrument_survey_titles
  # @param [ContactLink]
  # @param [Survey]
  # @return [Boolean]
  def instrument_exists_for_survey?(contact_link, survey)
    return false if survey.blank?

    previously_taken_survey_titles = contact_link.event.instrument_survey_titles
    return false if previously_taken_survey_titles.blank?

    previously_taken_survey_titles.include?(survey.title)
  end

  def show_continue_action(person, contact_link, event, participant)
    person && contact_link && continuable?(event, contact_link.contact) && participant.in_study?
  end

  def continuable?(event, contact)
    can_continue = event.consent_event? ? event.standalone_consent_event?(contact) : !event.closed?
    event.continuable? && can_continue
  end
  private :continuable?

  ##
  # To handle the internal_surveys, some surveys are started via
  # different actions in the people_controller
  def determine_consent_activity_path(person, activity, survey, contact_link)
    case survey.title
    when "IRB_CON_Informed_Consent", "IRB_CON_Reconsent", "IRB_CON_Withdrawal"
      start_consent_person_path(person, :participant_id => activity.participant.id,
                                        :survey_access_code => survey.access_code,
                                        :contact_link_id => contact_link.id)
    when "IRB_CON_NonInterviewReport"
      start_non_interview_report_person_path(person, :participant_id => activity.participant.id,
                                                     :survey_access_code => survey.access_code,
                                                     :contact_link_id => contact_link.id)
    else
      start_instrument_person_path(person, :participant_id => activity.participant.id,
                                           :references_survey_access_code => activity.references.to_s,
                                           :survey_access_code => survey.access_code,
                                           :contact_link_id => contact_link.id)
    end
  end
end
