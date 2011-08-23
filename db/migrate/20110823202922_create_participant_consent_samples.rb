class CreateParticipantConsentSamples < ActiveRecord::Migration
  def self.up
    create_table :participant_consent_samples do |t|

      t.string :psu_code,                      :null => false, :limit => 36
      t.binary :participant_consent_sample_id, :null => false
      t.references :participant
      t.references :participant_consent
      
      t.integer :sample_consent_type_code,     :null => false
      t.integer :sample_consent_given_code,    :null => false

      t.string :transaction_type,         :limit => 36

      t.timestamps
    end
  end

  def self.down
    drop_table :participant_consent_samples
  end
end
