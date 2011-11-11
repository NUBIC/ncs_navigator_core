module ParticipantsHelper
  include ActionView::Helpers::UrlHelper
  
  def switch_arm_message(participant)
    msg = "Switch from Low Intensity to High Intensity"
    msg = "Switch from High Intensity to Low Intensity" if participant.high_intensity
    msg
  end
  
  def psc_assignment_path(assignment_id)
    "#{NcsNavigator.configuration.psc_uri}pages/subject?assignment=#{assignment_id}"
  end
  
  def determine_participant_consent_path(activity, participant, contact_link)
    if participant.consented?
      consent = ParticipantConsent.where(:participant_id => participant.id).where(:contact_id => ContactLink.find(contact_link.id).contact.id).first
      link_to activity, edit_participant_consent_path(consent, :contact_link_id => contact_link.id), :class => "edit_link icon_link"
    else
      link_to activity, new_participant_consent_path(:participant_id => participant.id, :contact_link_id => contact_link.id), :class => "edit_link icon_link"
    end
  end
  
end