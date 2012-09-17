class NormalizeSpecimenTables < ActiveRecord::Migration
  def up
    create_table :specimen_storage_containers do |s|
      s.string :storage_container_id,       :null => false, :limit => 36
      s.references :specimen_shipping,      :null => true
      s.timestamps
    end
    add_foreign_key(:specimen_storage_containers, :specimen_shippings, :column => 'specimen_shipping_id', :name => 'specimen_storage_containers_specimen_shippings_fk', :options => 'DEFERRABLE')

    execute("ALTER TABLE specimen_receipts ALTER COLUMN specimen_id TYPE integer USING specimen_id::int")
    add_foreign_key(:specimen_receipts, :specimens, :column => 'specimen_id', :name => 'specimen_receipts_specimens_fk', :options => 'DEFERRABLE')

    execute("ALTER TABLE specimen_receipts ALTER COLUMN storage_container_id TYPE integer USING storage_container_id::int")
    add_foreign_key(:specimen_receipts, :specimen_storage_containers, :column => 'storage_container_id', :name => 'specimen_receipts_specimen_storage_containers_fk', :options => 'DEFERRABLE')

    execute("ALTER TABLE specimen_storages ALTER COLUMN storage_container_id TYPE integer USING storage_container_id::int")
    add_foreign_key(:specimen_storages, :specimen_storage_containers, :column => 'storage_container_id', :name => 'specimen_storages_specimen_storage_containers_fk', :options => 'DEFERRABLE')

    remove_column :specimen_shippings, :storage_container_id

    execute("ALTER TABLE specimen_receipt_confirmations ALTER COLUMN specimen_id TYPE integer USING specimen_id::int")
    add_foreign_key(:specimen_receipt_confirmations, :specimens, :column => 'specimen_id', :name => 'specimen_receipt_confirmations_specimens_fk', :options => 'DEFERRABLE')

    rename_column(:specimen_receipt_confirmations, :shipment_tracking_number, :shipment_tracking_number_id)
    execute("ALTER TABLE specimen_receipt_confirmations ALTER COLUMN shipment_tracking_number_id TYPE integer USING shipment_tracking_number_id::int")
    add_foreign_key(:specimen_receipt_confirmations, :specimen_shippings, :column => 'shipment_tracking_number_id', :name => 'specimen_receipt_confirmations_specimen_shippings_fk', :options => 'DEFERRABLE')

  end

  def down
    remove_foreign_key(:specimen_storage_containers, :name => 'specimen_storage_containers_specimen_shippings_fk')
    remove_foreign_key(:specimen_receipts, :name => 'specimen_receipts_specimen_storage_containers_fk')
    change_column :specimen_receipts, :storage_container_id, :string

    remove_foreign_key(:specimen_storages, :name => 'specimen_storages_specimen_storage_containers_fk')
    change_column :specimen_storages, :storage_container_id, :string

    drop_table :specimen_storage_containers

    remove_foreign_key(:specimen_receipts, :name => 'specimen_receipts_specimens_fk')
    change_column :specimen_receipts, :specimen_id, :string

    add_column :specimen_shippings, :storage_container_id, :string, :limit => 36, :null => false

    remove_foreign_key(:specimen_receipt_confirmations, :name => 'specimen_receipt_confirmations_specimens_fk')
    change_column :specimen_receipt_confirmations, :specimen_id, :string

    remove_foreign_key(:specimen_receipt_confirmations, :name => 'specimen_receipt_confirmations_specimen_shippings_fk')
    change_column :specimen_receipt_confirmations, :shipment_tracking_number_id, :string
    rename_column(:specimen_receipt_confirmations, :shipment_tracking_number_id, :shipment_tracking_number)
  end
end
