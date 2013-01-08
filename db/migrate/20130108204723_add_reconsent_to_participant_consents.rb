class AddReconsentToParticipantConsents < ActiveRecord::Migration
  def change
    add_column :participant_consents, :consent_reconsent_code, :integer, :null => false, :default => -4
    add_column :participant_consents, :consent_reconsent_reason_code, :integer, :null => false, :default => -4
    add_column :participant_consents, :consent_reconsent_reason_other, :string
  end
end
