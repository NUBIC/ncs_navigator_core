# -*- coding: utf-8 -*-

class CreateInstruments < ActiveRecord::Migration
  def self.up
    create_table :instruments do |t|

      t.integer :psu_code,                  :null => false, :limit => 36
      t.binary :instrument_id,              :null => false
      t.references :event
      t.integer :instrument_type_code,      :null => false
      t.string :instrument_type_other
      t.string :instrument_version,         :null => false, :limit => 36
      t.integer :instrument_repeat_key
      t.date :instrument_start_date
      t.string :instrument_start_time
      t.date :instrument_end_date
      t.string :instrument_end_time
      t.integer :instrument_breakoff_code,  :null => false
      t.integer :instrument_status_code,    :null => false
      t.integer :instrument_mode_code,      :null => false
      t.string :instrument_mode_other
      t.integer :instrument_method_code,    :null => false
      t.integer :supervisor_review_code,    :null => false
      t.integer :data_problem_code,         :null => false
      t.text :instrument_comment
      t.string :transaction_type

      t.timestamps
    end
  end

  def self.down
    drop_table :instruments
  end
end