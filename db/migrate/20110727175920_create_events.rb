# -*- coding: utf-8 -*-


class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|

      t.integer :psu_code,                  :null => false, :limit => 36
      t.binary :event_id,                   :null => false
      t.references :participant
      t.integer :event_type_code,           :null => false
      t.string :event_type_other
      t.integer :event_repeat_key
      t.integer :event_disposition
      t.integer :event_disposition_category_code, :null => false, :limit => 36
      t.date :event_start_date
      t.string :event_start_time
      t.date :event_end_date
      t.string :event_end_time
      t.integer :event_breakoff_code,       :null => false
      t.integer :event_incentive_type_code, :null => false
      t.decimal :event_incentive_cash,      :precision => 3, :scale => 2
      t.string :event_incentive_noncash
      t.text :event_comment
      t.string :transaction_type

      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end