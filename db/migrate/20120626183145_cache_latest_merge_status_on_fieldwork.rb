class CacheLatestMergeStatusOnFieldwork < ActiveRecord::Migration
  def up
    add_column :fieldworks, :latest_merge_status, :string
    add_column :fieldworks, :latest_merge_id, :integer
  end

  def down
    remove_column :fieldworks, :latest_merge_id
    remove_column :fieldworks, :latest_merge_status
  end
end
