# encoding: utf-8

class CreatePpgStatusHistories < ActiveRecord::Migration
  def self.up
    create_table :ppg_status_histories do |t|

      t.string :psu_code,                 :null => false, :limit => 36
      t.binary :ppg_history_id,           :null => false
      t.references :participant
      t.integer :ppg_status_code,         :null => false
      t.string :ppg_status_date,          :limit => 10
      t.integer :ppg_info_source_code,    :null => false
      t.string :ppg_info_source_other
      t.integer :ppg_info_mode_code,      :null => false
      t.string :ppg_info_mode_other
      t.text :ppg_comment
      t.string :transaction_type,         :limit => 36

      t.timestamps
    end
  end

  def self.down
    drop_table :ppg_status_histories
  end
end