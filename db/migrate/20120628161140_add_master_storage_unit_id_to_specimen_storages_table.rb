# -*- coding: utf-8 -*-
class AddMasterStorageUnitIdToSpecimenStoragesTable < ActiveRecord::Migration
  def up  
    add_column :specimen_storages, :master_storage_unit_id, :string
  end
  def down
    remove_column :specimen_storages, :master_storage_unit_id
  end
end
