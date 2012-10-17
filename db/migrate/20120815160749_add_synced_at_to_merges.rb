class AddSyncedAtToMerges < ActiveRecord::Migration
  def change
    add_column :merges, :synced_at, :datetime
  end
end
