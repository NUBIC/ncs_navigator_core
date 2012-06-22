class CreateSpecimenReceiptConfirmations < ActiveRecord::Migration
  def up
    create_table :specimen_receipt_confirmations do |t|
      t.integer :psu_code,                              :null => false
      t.references :specimen_processing_shipping_center
      t.integer :shipment_receipt_confirmed_code,       :null => false
      t.string :shipper_id,                             :null => false
      t.string :shipment_tracking_number,               :null => false
      t.datetime :shipment_receipt_datetime,            :null => false
      t.integer :shipment_condition_code,               :null => false
      t.string :shipment_damaged_reason
      t.string :specimen_id,                            :null => false
      t.decimal :specimen_receipt_temp,                 :null => false, :precision => 6, :scale => 2
      # t.integer :specimen_condition_code,                 :null => false
      t.string :specimen_condition
      t.string :shipment_received_by,                   :null => false
      t.string :transaction_type,                       :limit => 36      
      t.timestamps
    end
  end

  def down
    drop_table :specimen_receipt_confirmations
  end
end
