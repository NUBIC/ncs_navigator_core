# -*- coding: utf-8 -*-
module PbsListsHelper

  def provider_recruitment_link(pbs)
    active_provider_recruitment_link(pbs)
  end

  def active_provider_recruitment_link(pbs)
    link_to 'Enter Recruitment Contact', recruit_provider_pbs_list_path(pbs)
  end

  def pbs_eligibility_screener_link(person)
    if person.participant
      if person.participant.should_be_screened?
        link_to "Continue Eligibility Screener", new_person_contact_path(person),
          :class => "edit_link icon_link"
      else
        link_to "View Participant Record", participant_path(person.participant),
          :class => "show_link icon_link"
      end
    elsif person.sampled_ineligible?
      "Sampled Person is ineligible"
    else
      link_to "Administer Eligibility Screener",
        start_pbs_eligibility_screener_instrument_path(:person_id => person.id),
        :class => "add_link icon_link"
    end
  end

end
