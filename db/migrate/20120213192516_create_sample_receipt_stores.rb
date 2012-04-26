class CreateSampleReceiptStores < ActiveRecord::Migration
  def up
    create_table :sample_receipt_stores do |t|
      t.integer :psu_code,                      :null => false
      t.string :sample_id,                      :null => false, :limit => 36
      t.references :sample_receipt_shipping_center 
      t.string :staff_id,                       :null => false, :limit => 36
      t.integer :sample_condition_code,         :null => false
      t.string :receipt_comment_other,          :limit => 255
      t.datetime :receipt_datetime,             :null => false
      t.integer :cooler_temp_condition_code,    :null => false
      t.references :environmental_equipment
      t.datetime :placed_in_storage_datetime,   :null => false
      t.integer :storage_compartment_area_code, :null => false
      t.string :storage_comment_other,          :limit => 255
      t.datetime :removed_from_storage_datetime
      t.integer :temp_event_occurred_code,      :null => false
      t.integer :temp_event_action_code,        :null => false
      t.string :temp_event_action_other,        :limit => 255
      t.string :transaction_type,               :limit => 36
      t.timestamps
    end
  end

  def down
    drop_table :sample_receipt_stores
  end
end