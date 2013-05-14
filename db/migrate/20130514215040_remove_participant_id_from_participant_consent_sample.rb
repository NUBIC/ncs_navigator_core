class RemoveParticipantIdFromParticipantConsentSample < ActiveRecord::Migration
  def up
    remove_column :participant_consent_samples, :participant_id
  end

  def down
    add_column :participant_consent_samples, :participant_id
  end
end
