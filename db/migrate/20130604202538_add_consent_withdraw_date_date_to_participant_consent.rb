class AddConsentWithdrawDateDateToParticipantConsent < ActiveRecord::Migration
  def change
    add_column :participant_consents, :consent_withdraw_date_date, :date
    execute("UPDATE participant_consents SET consent_withdraw_date_date = consent_withdraw_date")

    remove_column :participant_consents, :consent_withdraw_date
    add_column :participant_consents, :consent_withdraw_date, :string, :limit => 255

    ParticipantConsent.reset_column_information
    execute("UPDATE participant_consents SET consent_withdraw_date = to_char(consent_withdraw_date_date, 'YYYY-MM-DD')")
  end
end
