class AddInternalIdToFieldworks < ActiveRecord::Migration
  def change
    add_column :fieldworks, :id, :primary_key
  end
end
