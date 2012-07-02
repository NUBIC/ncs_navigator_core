# -*- coding: utf-8 -*-
class AddAddressIdToSpscAndSrscTables < ActiveRecord::Migration
  def up
    add_column :specimen_processing_shipping_centers, :address_id, :integer
    add_foreign_key(:specimen_processing_shipping_centers, :addresses, :column => 'address_id', :name => 'specimen_processing_shipping_centers_addresses_fk', :options => 'DEFERRABLE')
    
    add_column :sample_receipt_shipping_centers, :address_id, :integer
    add_foreign_key(:sample_receipt_shipping_centers, :addresses, :column => 'address_id', :name => 'sample_receipt_shipping_centers_addresses_fk', :options => 'DEFERRABLE')    
    
    remove_column :addresses, :specimen_processing_shipping_center_id
    remove_column :addresses, :sample_receipt_shipping_center_id
  end

  def down
    remove_foreign_key(:specimen_processing_shipping_centers, :name => 'specimen_processing_shipping_centers_addresses_fk')
    remove_foreign_key(:sample_receipt_shipping_centers, :name => 'sample_receipt_shipping_centers_addresses_fk')
    
    remove_column :specimen_processing_shipping_centers, :address_id
    remove_column :sample_receipt_shipping_centers, :address_id

    add_column :addresses, :specimen_processing_shipping_center_id, :integer, :null => true
    add_column :addresses, :sample_receipt_shipping_center_id, :integer, :null => true
  end
end
