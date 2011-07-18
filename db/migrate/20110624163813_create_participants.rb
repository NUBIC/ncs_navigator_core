class CreateParticipants < ActiveRecord::Migration
  def self.up
    create_table :participants do |t|

      t.string :psu_code,                       :null => false, :limit => 36
      t.binary :p_id,                           :null => false
      t.references :person,                     :null => false
      t.integer :p_type_code,                   :null => false
      t.string :p_type_other,                   :limit => 255
      t.integer :status_info_source_code,       :null => false
      t.string :status_info_source_other,       :limit => 255
      t.integer :status_info_mode_code,         :null => false
      t.string :status_info_mode_other,         :limit => 255
      t.date :status_info_date
      t.integer :enroll_status_code,            :null => false
      t.date :enroll_date
      t.integer :pid_entry_code,                :null => false
      t.string :pid_entry_other,                :limit => 255
      t.integer :pid_age_eligibility_code,      :null => false
      t.text :pid_comment
      t.string :transaction_type,               :limit => 36

      t.timestamps
    end
  end

  def self.down
    drop_table :participants
  end
end
