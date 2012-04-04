class AddMergeStatusToFieldwork < ActiveRecord::Migration
  def change
    add_column :fieldworks, :merged, :boolean, :default => false
  end
end
