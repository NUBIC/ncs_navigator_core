# -*- coding: utf-8 -*-


module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the home\s?page/
      '/'

    when /the welcome summary page/
      '/welcome/summary'

    when /the welcome index page/
      '/'

    when /login/
      '/login'

    when /logout/
      '/logout'

    when /^the household units page$/
      household_units_path

    when /^the edit household unit page$/
      edit_household_unit_path(HouseholdUnit.last)

    when /^the dwelling units page$/
      dwelling_units_path

    when /^the edit dwelling unit page$/
      edit_dwelling_unit_path(DwellingUnit.last)

    when /^the people page$/
      people_path

    when /^the edit person page$/
      edit_person_path(Person.last)

    when /^the events_person page$/
      events_person_path(Participant.first.person.id)

    when /^the new_person_contact page$/
      new_person_contact_path(Participant.last.person.id)

    when /^the edit_person_contact page$/
      edit_person_contact_path(Participant.first.person.id, Contact.last)

    when /^the new child page for a participant and contact link$/
      new_child_people_path(:participant_id => Participant.last.id,
                            :contact_link_id => ContactLink.last.id)

    when /^the edit child page for a participant and contact link$/
      edit_child_person_path(Person.last,
                             :participant_id => Participant.last.id,
                             :contact_link_id => ContactLink.last.id)

    when /^the new participant page for that person$/
      new_participant_path(:person_id => Person.last.id)

    when /^the new participant page for that participant$/
      new_participant_path(:person_id => Participant.last.person.id)

    when /^the edit participant page$/
      edit_participant_path(Participant.last)

    when /^the participant page$/
      participant_path(Participant.last)

    when /^the ppg1 page$/
      in_ppg_group_participants_path

    when /^the edit_arm_participant page$/
      edit_arm_participant_path(Participant.last)

    when /^the edit_contact_link page$/
      edit_contact_link_path(ContactLink.last)

    when /^the edit_contact_link_contact page$/
      contact_link = ContactLink.last
      edit_contact_link_contact_path(contact_link, contact_link.contact)

    when /^the edit_contact_link_event page$/
      contact_link = ContactLink.last
      edit_contact_link_event_path(contact_link, contact_link.event)

    when /^the decision_page_contact_link page$/
      decision_page_contact_link_path(ContactLink.last)

    when /^the post-consent decision_page_contact_link page$/
      decision_page_contact_link_path(ContactLink.first)

    when /^the edit_instrument_contact_link page$/
      edit_instrument_contact_link_path(ContactLink.last)

    when /^the edit_participant_visit_record page$/
      edit_participant_visit_record_path(ParticipantVisitRecord.last)

    when /^the select_instrument_contact_link page$/
      select_instrument_contact_link_path(ContactLink.last)

    when /^the decision_page_contact_link page$/
      decision_page_contact_link_path(ContactLink.last)

    when /^the consent_contact_link page$/
      consent_contact_link_path(ContactLink.last)

    when /^the new contact path for the participant$/
      new_person_contact_path(:person_id => Participant.last.person.id)

    when /^the field client activity page$/
      fieldwork_index_path

    when /^the latest sync attempt page for "([^"]*)"$/
      latest_fieldwork_merges_path($1)

    # the following are examples using path_to_pickle

    when /^#{capture_model}(?:'s)? page$/                           # eg. the forum's page
      path_to_pickle $1

    when /^#{capture_model}(?:'s)? #{capture_model}(?:'s)? page$/   # eg. the forum's post's page
      path_to_pickle $1, $2

    when /^#{capture_model}(?:'s)? #{capture_model}'s (.+?) page$/  # eg. the forum's post's comments page
      path_to_pickle $1, $2, :extra => $3                           #  or the forum's post's edit page

    when /^#{capture_model}(?:'s)? (.+?) page$/                     # eg. the forum's posts page
      path_to_pickle $1, :extra => $2                               #  or the forum's edit page

    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      begin
        page_name =~ /the (.*) page/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)