# encoding: utf-8

class CreateParticipantConsents < ActiveRecord::Migration
  def self.up
    create_table :participant_consents do |t|

      t.string :psu_code,                       :null => false, :limit => 36
      t.binary :participant_consent_id,         :null => false
      t.references :participant
      t.string :consent_version,                :limit => 9
      t.date :consent_expiration
      t.integer :consent_type_code,             :null => false
      t.integer :consent_form_type_code,        :null => false
      t.integer :consent_given_code,            :null => false
      t.date :consent_date
      t.integer :consent_withdraw_code,         :null => false
      t.integer :consent_withdraw_type_code,    :null => false
      t.integer :consent_withdraw_reason_code,  :null => false
      t.date :consent_withdraw_date
      t.integer :consent_language_code,         :null => false
      t.string :consent_language_other
      t.integer :person_who_consented_id
      t.integer :who_consented_code,            :null => false
      t.integer :person_wthdrw_consent_id
      t.integer :who_wthdrw_consent_code,       :null => false
      t.integer :consent_translate_code,        :null => false
      t.text :consent_comments
      t.references :contact
      t.integer :reconsideration_script_use_code, :null => false
      t.string :transaction_type,               :limit => 36

      t.timestamps
    end
  end

  def self.down
    drop_table :participant_consents
  end
end