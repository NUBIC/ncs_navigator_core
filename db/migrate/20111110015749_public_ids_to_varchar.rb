class PublicIdsToVarchar < ActiveRecord::Migration
  def tables_to_public_ids
    [
      [ :addresses, :address_id ],
      [ :contacts, :contact_id ],
      [ :contact_links, :contact_link_id ],
      [ :dwelling_household_links, :hh_du_id ],
      [ :dwelling_units, :du_id ],
      [ :emails, :email_id ],
      [ :events, :event_id ],
      [ :household_person_links, :person_hh_id ],
      [ :household_units, :hh_id ],
      [ :instruments, :instrument_id ],
      [ :listing_units, :list_id ],
      [ :participants, :p_id ],
      [ :participant_authorization_forms, :auth_form_id ],
      [ :participant_consents, :participant_consent_id ],
      [ :participant_consent_samples, :participant_consent_sample_id ],
      [ :participant_person_links, :person_pid_id ],
      [ :participant_visit_consents, :pid_visit_consent_id ],
      [ :participant_visit_records, :rvis_id ],
      [ :people, :person_id ],
      [ :person_races, :person_race_id ],
      [ :ppg_details, :ppg_details_id ],
      [ :ppg_status_histories, :ppg_history_id ],
      [ :telephones, :phone_id ]
    ]
  end

  def up
    tables_to_public_ids.each do |table, public_id|
      execute "ALTER TABLE #{table} ALTER COLUMN #{public_id} TYPE VARCHAR(36)"
    end
  end

  def down
    # PGError: ERROR:  column "___" cannot be cast to type bytea
    # tables_to_public_ids.each do |table, public_id|
    #   execute "ALTER TABLE #{table} ALTER COLUMN #{public_id} TYPE BYTEA"
    # end
  end
end
