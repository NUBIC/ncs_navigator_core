class AllPsuCodesToIntegers < ActiveRecord::Migration
  AFFECTED_TABLES = %w(
    household_person_links participants participant_authorization_forms participant_consents
    participant_consent_samples participant_person_links participant_visit_consents
    participant_visit_records people person_races ppg_details ppg_status_histories
  )

  def up
    AFFECTED_TABLES.each do |t|
      execute("ALTER TABLE #{t} ALTER COLUMN psu_code TYPE INTEGER USING psu_code::integer")
    end
  end

  def down
    AFFECTED_TABLES.reverse.each do |t|
      execute("ALTER TABLE #{t} ALTER COLUMN psu_code TYPE VARCHAR(36)")
    end
  end
end
