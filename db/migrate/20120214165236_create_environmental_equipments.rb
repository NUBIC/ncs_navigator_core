# -*- coding: utf-8 -*-
class CreateEnvironmentalEquipments < ActiveRecord::Migration
  def up
    create_table :environmental_equipments do |t|
      t.integer :psu_code,                    :null => false
      t.references :sample_receipt_shipping_center 
      t.string :equipment_id,                 :null => false, :limit => 36
      t.integer :equipment_type_code,         :null => false
      t.string :equipment_type_other,         :limit => 255
      t.string :serial_number,                :null => false, :limit => 50
      t.string :government_asset_tag_number,  :limit => 36
      t.string :retired_date,                 :limit => 10
      t.integer :retired_reason_code,         :null => false
      t.string :retired_reason_other,         :limit => 255
      t.string :transaction_type,             :limit => 36      
      t.timestamps
    end
  end

  def down
    drop_table :environmental_equipments
  end
end