class AddConflictReportToFieldwork < ActiveRecord::Migration
  def change
    add_column :fieldworks, :conflict_report, :text
  end
end
