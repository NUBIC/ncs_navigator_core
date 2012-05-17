class MoveMergeDataToMerges < ActiveRecord::Migration
  def up
    Fieldwork.find_in_batches(:include => :merges) do |batch|
      batch.each do |fw|
        if fw.merges.empty?
          fw.merges.create!(:received_data => fw.received_data,
                            :log => fw.merge_log,
                            :completed_at => (fw.updated_at if fw.merged),
                            :conflict_report => fw.conflict_report)
        end
      end
    end

    remove_column :fieldworks, :conflict_report
    remove_column :fieldworks, :merge_log
    remove_column :fieldworks, :merged
    remove_column :fieldworks, :received_data
  end

  def down
    add_column :fieldworks, :conflict_report, :text
    add_column :fieldworks, :merge_log, :text
    add_column :fieldworks, :merged, :boolean
    add_column :fieldworks, :received_data, :binary
  end
end
