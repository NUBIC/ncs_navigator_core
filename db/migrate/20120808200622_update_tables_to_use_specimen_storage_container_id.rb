class UpdateTablesToUseSpecimenStorageContainerId < ActiveRecord::Migration
  def up
    rename_column(:specimen_receipts, :storage_container_id, :specimen_storage_container_id)
    rename_column(:specimen_storages, :storage_container_id, :specimen_storage_container_id)    
  end

  def down
    rename_column(:specimen_receipts, :specimen_storage_container_id, :storage_container_id)
    rename_column(:specimen_storages, :storage_container_id, :specimen_storage_container_id)
  end
end
