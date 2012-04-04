class AddLogsToFieldwork < ActiveRecord::Migration
  def change
    add_column :fieldworks, :generation_log, :text
    add_column :fieldworks, :merge_log, :text
  end
end
