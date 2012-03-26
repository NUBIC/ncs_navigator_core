class CreateParticipantVisitRecords < ActiveRecord::Migration
  def self.up
    create_table :participant_visit_records do |t|

      t.string :psu_code,                     :null => false, :limit => 36
      t.binary :rvis_id,                      :null => false
      t.references :participant

      t.integer :rvis_language_code,          :null => false
      t.string :rvis_language_other
      t.integer :rvis_person_id

      t.integer :rvis_who_consented_code,     :null => false
      t.integer :rvis_translate_code,         :null => false
      t.references :contact

      t.datetime :time_stamp_1
      t.datetime :time_stamp_2

      t.integer :rvis_sections_code,          :null => false
      t.integer :rvis_during_interv_code,     :null => false
      t.integer :rvis_during_bio_code,        :null => false
      t.integer :rvis_bio_cord_code,          :null => false
      t.integer :rvis_during_env_code,        :null => false
      t.integer :rvis_during_thanks_code,     :null => false
      t.integer :rvis_after_saq_code,         :null => false
      t.integer :rvis_reconsideration_code,   :null => false

      t.string :transaction_type,             :limit => 36

      t.timestamps
    end
  end

  def self.down
    drop_table :participant_visit_records
  end
end
