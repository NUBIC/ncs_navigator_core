class CreateSampleReceiptConfirmations < ActiveRecord::Migration
  def up
    create_table :sample_receipt_confirmations do |t|
      t.integer :psu_code,                              :null => false
      t.references :sample_receipt_shipping_center
      t.integer :shipment_receipt_confirmed_code,       :null => false
      t.string :shipper_id,                             :null => false
      t.string :shipment_tracking_number,               :null => false
      t.datetime :shipment_receipt_datetime,            :null => false
      t.integer :shipment_condition_code,               :null => false
      t.string :shipment_damaged_reason
      t.string :sample_id,                              :null => false
      t.decimal :sample_receipt_temp,                   :null => false, :precision => 6, :scale => 2
      t.integer :sample_condition_code,                 :null => false
      t.string :shipment_received_by,                   :null => false
      t.string :transaction_type,                       :limit => 36      
      t.timestamps
    end
  end

  def down
    drop_table :sample_receipt_confirmations
  end
end