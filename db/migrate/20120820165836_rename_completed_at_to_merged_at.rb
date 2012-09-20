class RenameCompletedAtToMergedAt < ActiveRecord::Migration
  def up
    rename_column :merges, :completed_at, :merged_at
  end

  def down
    rename_column :merges, :merged_at, :completed_at
  end
end
