class AddSpecimenIdToSpecimenPickup < ActiveRecord::Migration
  def up
    add_column :specimen_pickups, :specimen_id, :string, :limit => 36, :null => false
  end
  def down
    remove_column :specimen_pickups, :specimen_id
  end
end
