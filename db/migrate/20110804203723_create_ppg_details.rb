class CreatePpgDetails < ActiveRecord::Migration
  def self.up
    create_table :ppg_details do |t|
      
      t.string :psu_code,                 :null => false, :limit => 36
      t.binary :ppg_details_id,           :null => false
      t.references :participant
      t.integer :ppg_pid_status_code,     :null => false
      t.integer :ppg_first_code,          :null => false
      t.string :orig_due_date,            :limit => 10
      t.string :due_date_2,               :limit => 10
      t.string :due_date_3,               :limit => 10
      t.string :transaction_type,         :limit => 36
      
      t.timestamps
    end
  end

  def self.down
    drop_table :ppg_details
  end
end
