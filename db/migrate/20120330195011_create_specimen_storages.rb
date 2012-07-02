# -*- coding: utf-8 -*-
class CreateSpecimenStorages < ActiveRecord::Migration
  def up
    create_table :specimen_storages do |t|
      t.integer :psu_code,                              :null => false
      t.references :specimen_processing_shipping_center 
      t.string :storage_container_id,                   :null => false, :limit => 36
      t.datetime :placed_in_storage_datetime
      t.string :staff_id,                               :null => false, :limit => 36
      t.references :specimen_equipment
      t.integer :master_storage_unit_code,              :null => false
      t.string :storage_comment,                        :null => false, :limit => 255
      t.string :storage_comment_other,                  :limit => 255
      # required field!!
      t.datetime :removed_from_storage_datetime
      t.string :temp_event_starttime,                   :limit => 5
      t.string :temp_event_endtime,                     :limit => 5
      t.decimal :temp_event_low_temp,                   :precision => 6, :scale => 2
      t.decimal :temp_event_high_temp,                  :precision => 6, :scale => 2
      t.string :transaction_type,                       :limit => 36      
      t.timestamps
    end
  end

  def down
    drop_table :specimen_storages
  end
end