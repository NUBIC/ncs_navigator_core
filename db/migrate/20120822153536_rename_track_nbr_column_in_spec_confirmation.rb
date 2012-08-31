class RenameTrackNbrColumnInSpecConfirmation < ActiveRecord::Migration
  def up
    remove_foreign_key(:specimen_receipt_confirmations, :name => 'specimen_receipt_confirmations_specimen_shippings_fk')
    rename_column(:specimen_receipt_confirmations, :shipment_tracking_number_id, :specimen_shipping_id)
    add_foreign_key(:specimen_receipt_confirmations, :specimen_shippings, :column => 'specimen_shipping_id', :name => 'specimen_receipt_confirmations_specimen_shippings_fk', :options => 'DEFERRABLE')
  end

  def down
    remove_foreign_key(:specimen_receipt_confirmations, :name => 'specimen_receipt_confirmations_specimen_shippings_fk')
    rename_column(:specimen_receipt_confirmations, :specimen_shipping_id, :shipment_tracking_number_id)
    add_foreign_key(:specimen_receipt_confirmations, :specimen_shippings, :column => 'shipment_tracking_number_id', :name => 'specimen_receipt_confirmations_specimen_shippings_fk', :options => 'DEFERRABLE')    
  end
end
