class CreateSpecimenShippings < ActiveRecord::Migration
  def up
    create_table :specimen_shippings do |t|
      t.integer :psu_code,                              :null => false
      t.string :storage_container_id,                   :null => false, :limit => 36
      t.references :specimen_processing_shipping_center 
      t.string :staff_id,                               :null => false, :limit => 36
      t.string :shipper_id,                             :null => false, :limit => 36
      t.string :shipper_destination,                    :null => false, :limit => 3
      t.string :shipment_date,                          :null => false, :limit => 10
      t.integer :shipment_temperature_code,             :null => false
      t.string :shipment_tracking_number,               :null => false, :limit => 36
      t.integer :shipment_receipt_confirmed_code,       :null => false
      t.datetime :shipment_receipt_datetime
      t.integer :shipment_issues_code,                  :null => false
      t.string :shipment_issues_other,                  :limit => 255
      t.string :transaction_type,                       :limit => 36      
      t.timestamps
    end
  end

  def down
    drop_table :specimen_shippings
  end
end
