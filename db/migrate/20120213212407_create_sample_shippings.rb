# -*- coding: utf-8 -*-
class CreateSampleShippings < ActiveRecord::Migration
  def up
    create_table :sample_shippings do |t|
      t.integer :psu_code,                              :null => false
      t.string :sample_id,                              :null => false, :limit => 36
      t.references :sample_receipt_shipping_center 
      t.string :staff_id,                               :null => false, :limit => 36
      t.string :shipper_id,                             :null => false, :limit => 36
      t.integer :shipper_destination_code,              :null => false
      t.string :shipment_date,                          :null => false, :limit => 10
      t.integer :shipment_coolant_code,                 :null => false
      t.string :shipment_tracking_number,               :null => false, :limit => 36      
      t.string :shipment_issues_other,                  :limit => 255
      t.string :staff_id_track,                         :limit => 36
      t.integer :sample_shipped_by_code,                :null => false, :limit => 3
      t.string :transaction_type,                       :limit => 36      
      t.timestamps
    end
  end

  def down
    drop_table :sample_shippings
  end
end
