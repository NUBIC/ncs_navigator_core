# -*- coding: utf-8 -*-
class CreateSpecimenReceipts < ActiveRecord::Migration
  def up
    create_table :specimen_receipts do |t|
      t.integer :psu_code,                  :null => false
      t.string :specimen_id,                :null => false, :limit => 36
      t.references :specimen_processing_shipping_center 
      t.string :staff_id,                   :null => false, :limit => 36
      t.integer :receipt_comment_code,      :null => false
      t.string :receipt_comment_other,        :limit => 255
      t.datetime :receipt_datetime,               :null => false
      t.decimal :cooler_temp,               :precision => 6, :scale => 2
      t.integer :monitor_status_code
      t.integer :upper_trigger_code
      t.integer :upper_trigger_level_code
      t.integer :lower_trigger_cold_code
      t.integer :lower_trigger_ambient_code
      t.string :storage_container_id,       :null => false, :limit => 36    # external id but not references anything
      t.integer :centrifuge_comment_code
      t.string :centrifuge_comment_other,     :limit => 255
      t.string :centrifuge_starttime,              :limit => 5
      t.string :centrifuge_endtime,              :limit => 5
      t.string :centrifuge_staff_id,        :limit => 36
      t.references :specimen_equipment
      t.string :transaction_type,           :limit => 36
      t.timestamps
    end
  end

  def down
    drop_table :specimen_receipts
  end
end