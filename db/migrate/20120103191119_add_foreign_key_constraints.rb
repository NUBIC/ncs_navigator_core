class AddForeignKeyConstraints < ActiveRecord::Migration
  def up
    # add_foreign_key(:from, :to, :column => 'xxx_id', :name => 'from_to_fk')

    add_foreign_key(:addresses, :people, :column => 'person_id', :name => 'addresses_people_fk', :options => 'DEFERRABLE')
    add_foreign_key(:addresses, :dwelling_units, :column => 'dwelling_unit_id', :name => 'addresses_dwelling_units_fk', :options => 'DEFERRABLE')

    add_foreign_key(:contact_links, :contacts, :column => 'contact_id', :name => 'contact_links_contact_fk', :options => 'DEFERRABLE')
    add_foreign_key(:contact_links, :people, :column => 'person_id', :name => 'contact_links_people_fk', :options => 'DEFERRABLE')
    add_foreign_key(:contact_links, :events, :column => 'event_id', :name => 'contact_links_events_fk', :options => 'DEFERRABLE')
    add_foreign_key(:contact_links, :instruments, :column => 'instrument_id', :name => 'contact_links_instruments_fk', :options => 'DEFERRABLE')

    add_foreign_key(:dwelling_household_links, :dwelling_units, :column => 'dwelling_unit_id', :name => 'dwelling_household_links_dwelling_units_fk', :options => 'DEFERRABLE')
    add_foreign_key(:dwelling_household_links, :household_units, :column => 'household_unit_id', :name => 'dwelling_household_links_household_units_fk', :options => 'DEFERRABLE')

    add_foreign_key(:dwelling_units, :listing_units, :column => 'listing_unit_id', :name => 'dwelling_units_listing_units_fk', :options => 'DEFERRABLE')

    add_foreign_key(:emails, :people, :column => 'person_id', :name => 'emails_people_fk', :options => 'DEFERRABLE')

    add_foreign_key(:events, :participants, :column => 'participant_id', :name => 'events_participants_fk', :options => 'DEFERRABLE')

    add_foreign_key(:household_person_links, :people, :column => 'person_id', :name => 'household_person_links_people_fk', :options => 'DEFERRABLE')
    add_foreign_key(:household_person_links, :household_units, :column => 'household_unit_id', :name => 'household_person_links_household_units_fk', :options => 'DEFERRABLE')

    add_foreign_key(:instruments, :events, :column => 'event_id', :name => 'instruments_events_fk', :options => 'DEFERRABLE')
    add_foreign_key(:instruments, :people, :column => 'person_id', :name => 'instruments_people_fk', :options => 'DEFERRABLE')
    add_foreign_key(:instruments, :surveys, :column => 'survey_id', :name => 'instruments_surveys_fk', :options => 'DEFERRABLE')

    add_foreign_key(:participant_authorization_forms, :participants, :column => 'participant_id', :name => 'participant_authorization_forms_participants_fk', :options => 'DEFERRABLE')
    add_foreign_key(:participant_authorization_forms, :contacts, :column => 'contact_id', :name => 'participant_authorization_forms_contacts_fk', :options => 'DEFERRABLE')
    # add_foreign_key(:participant_authorization_forms, :providers, :column => 'provider_id', :name => 'participant_authorization_forms_providers_fk', :options => 'DEFERRABLE')

    add_foreign_key(:participant_consents, :participants, :column => 'participant_id', :name => 'participant_consents_participants_fk', :options => 'DEFERRABLE')
    add_foreign_key(:participant_consents, :contacts, :column => 'contact_id', :name => 'participant_consents_contacts_fk', :options => 'DEFERRABLE')
    add_foreign_key(:participant_consents, :people, :column => 'person_who_consented_id', :name => 'participant_consents_person_consented_fk', :options => 'DEFERRABLE')
    add_foreign_key(:participant_consents, :people, :column => 'person_wthdrw_consent_id', :name => 'participant_consents_person_withdrew_fk', :options => 'DEFERRABLE')

    add_foreign_key(:participant_consent_samples, :participants, :column => 'participant_id', :name => 'participant_consent_samples_participants_fk', :options => 'DEFERRABLE')
    add_foreign_key(:participant_consent_samples, :participant_consents, :column => 'participant_consent_id', :name => 'participant_consent_samples_participant_consents_fk', :options => 'DEFERRABLE')

    add_foreign_key(:participant_high_intensity_state_transitions, :participants, :column => 'participant_id', :name => 'participant_high_intensity_state_transitions_participants_fk', :options => 'DEFERRABLE')

    add_foreign_key(:participant_low_intensity_state_transitions, :participants, :column => 'participant_id', :name => 'participant_low_intensity_state_transitions_participants_fk', :options => 'DEFERRABLE')

    add_foreign_key(:participant_person_links, :participants, :column => 'participant_id', :name => 'participant_person_links_participants_fk', :options => 'DEFERRABLE')
    add_foreign_key(:participant_person_links, :people, :column => 'person_id', :name => 'participant_person_links_people_fk', :options => 'DEFERRABLE')

    add_foreign_key(:participant_staff_relationships, :participants, :column => 'participant_id', :name => 'participant_staff_relationships_participants_fk', :options => 'DEFERRABLE')

    add_foreign_key(:participant_visit_consents, :participants, :column => 'participant_id', :name => 'participant_visit_consents_participants_fk', :options => 'DEFERRABLE')
    add_foreign_key(:participant_visit_consents, :contacts, :column => 'contact_id', :name => 'participant_visit_consents_contacts_fk', :options => 'DEFERRABLE')
    add_foreign_key(:participant_visit_consents, :people, :column => 'vis_person_who_consented_id', :name => 'participant_visit_consents_people_fk', :options => 'DEFERRABLE')

    add_foreign_key(:participant_visit_records, :participants, :column => 'participant_id', :name => 'participant_visit_records_participants_fk', :options => 'DEFERRABLE')
    add_foreign_key(:participant_visit_records, :contacts, :column => 'contact_id', :name => 'participant_visit_records_contacts_fk', :options => 'DEFERRABLE')
    add_foreign_key(:participant_visit_records, :people, :column => 'rvis_person_id', :name => 'participant_visit_records_people_fk', :options => 'DEFERRABLE')

    add_foreign_key(:person_races, :people, :column => 'person_id', :name => 'person_races_people_fk', :options => 'DEFERRABLE')

    add_foreign_key(:ppg_details, :participants, :column => 'participant_id', :name => 'ppg_details_participants_fk', :options => 'DEFERRABLE')

    add_foreign_key(:ppg_status_histories, :participants, :column => 'participant_id', :name => 'ppg_status_histories_participants_fk', :options => 'DEFERRABLE')

    add_foreign_key(:response_sets, :people, :column => 'user_id', :name => 'response_sets_people_fk', :options => 'DEFERRABLE')
    add_foreign_key(:response_sets, :instruments, :column => 'instrument_id', :name => 'response_sets_instruments_fk', :options => 'DEFERRABLE')

    add_foreign_key(:telephones, :people, :column => 'person_id', :name => 'telephones_people_fk', :options => 'DEFERRABLE')

  end

  def down
    # remove_foreign_key(:from, :name => 'from_to_fk')

    remove_foreign_key(:addresses, :name => 'addresses_people_fk')
    remove_foreign_key(:addresses, :name => 'addresses_dwelling_units_fk')

    remove_foreign_key(:contact_links, :name => 'contact_links_contact_fk')
    remove_foreign_key(:contact_links, :name => 'contact_links_people_fk')
    remove_foreign_key(:contact_links, :name => 'contact_links_events_fk')
    remove_foreign_key(:contact_links, :name => 'contact_links_instruments_fk')

    remove_foreign_key(:dwelling_household_links, :name => 'dwelling_household_links_dwelling_units_fk')
    remove_foreign_key(:dwelling_household_links, :name => 'dwelling_household_links_household_units_fk')

    remove_foreign_key(:dwelling_units, :name => 'dwelling_units_listing_units_fk')

    remove_foreign_key(:emails, :name => 'emails_people_fk')

    remove_foreign_key(:events, :name => 'events_participants_fk')

    remove_foreign_key(:household_person_links, :name => 'household_person_links_people_fk')
    remove_foreign_key(:household_person_links, :name => 'household_person_links_household_units_fk')

    remove_foreign_key(:instruments, :name => 'instruments_events_fk')
    remove_foreign_key(:instruments, :name => 'instruments_people_fk')
    remove_foreign_key(:instruments, :name => 'instruments_surveys_fk')

    remove_foreign_key(:participant_authorization_forms, :name => 'participant_authorization_forms_participants_fk')
    remove_foreign_key(:participant_authorization_forms, :name => 'participant_authorization_forms_contacts_fk')
    # remove_foreign_key(:participant_authorization_forms, :name => 'participant_authorization_forms_providers_fk')

    remove_foreign_key(:participant_consents, :name => 'participant_consents_participants_fk')
    remove_foreign_key(:participant_consents, :name => 'participant_consents_contacts_fk')
    remove_foreign_key(:participant_consents, :name => 'participant_consents_person_consented_fk')
    remove_foreign_key(:participant_consents, :name => 'participant_consents_person_withdrew_fk')

    remove_foreign_key(:participant_consent_samples, :name => 'participant_consent_samples_participants_fk')
    remove_foreign_key(:participant_consent_samples, :name => 'participant_consent_samples_participant_consents_fk')

    remove_foreign_key(:participant_high_intensity_state_transitions, :name => 'participant_high_intensity_state_transitions_participants_fk')

    remove_foreign_key(:participant_low_intensity_state_transitions, :name => 'participant_low_intensity_state_transitions_participants_fk')

    remove_foreign_key(:participant_person_links, :name => 'participant_person_links_participants_fk')
    remove_foreign_key(:participant_person_links, :name => 'participant_person_links_people_fk')

    remove_foreign_key(:participant_staff_relationships, :name => 'participant_staff_relationships_participants_fk')

    remove_foreign_key(:participant_visit_consents, :name => 'participant_visit_consents_participants_fk')
    remove_foreign_key(:participant_visit_consents, :name => 'participant_visit_consents_contacts_fk')
    remove_foreign_key(:participant_visit_consents, :name => 'participant_visit_consents_people_fk')

    remove_foreign_key(:participant_visit_records, :name => 'participant_visit_records_participants_fk')
    remove_foreign_key(:participant_visit_records, :name => 'participant_visit_records_contacts_fk')
    remove_foreign_key(:participant_visit_records, :name => 'participant_visit_records_people_fk')

    remove_foreign_key(:person_races, :name => 'person_races_people_fk')

    remove_foreign_key(:ppg_details, :name => 'ppg_details_participants_fk')

    remove_foreign_key(:ppg_status_histories, :name => 'ppg_status_histories_participants_fk')

    remove_foreign_key(:response_sets, :name => 'response_sets_people_fk')
    remove_foreign_key(:response_sets, :name => 'response_sets_instruments_fk')

    remove_foreign_key(:telephones, :name => 'telephones_people_fk')

  end
end
