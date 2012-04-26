# -*- coding: utf-8 -*-

class CreateParticipantVisitConsents < ActiveRecord::Migration
  def self.up
    create_table :participant_visit_consents do |t|

      t.string :psu_code,                   :null => false, :limit => 36
      t.binary :pid_visit_consent_id,       :null => false
      t.references :participant
      t.integer :vis_consent_type_code,     :null => false
      t.integer :vis_consent_response_code, :null => false
      t.integer :vis_language_code,         :null => false
      t.string :vis_language_other
      t.integer :vis_person_who_consented_id
      t.integer :vis_who_consented_code,    :null => false
      t.integer :vis_translate_code,        :null => false
      t.text :vis_comments
      t.references :contact
      t.string :transaction_type,           :limit => 36

      t.timestamps
    end
  end

  def self.down
    drop_table :participant_visit_consents
  end
end