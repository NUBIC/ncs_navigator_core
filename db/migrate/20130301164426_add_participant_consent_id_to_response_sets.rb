class AddParticipantConsentIdToResponseSets < ActiveRecord::Migration
  def change
    add_column :response_sets, :participant_consent_id, :integer
  end
end
