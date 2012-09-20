class AddStaffIdToMerges < ActiveRecord::Migration
  def change
    add_column :merges, :staff_id, :string, :length => 36
  end
end
