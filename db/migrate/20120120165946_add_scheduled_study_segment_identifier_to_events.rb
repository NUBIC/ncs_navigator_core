class AddScheduledStudySegmentIdentifierToEvents < ActiveRecord::Migration
  def change
    add_column :events, :scheduled_study_segment_identifier, :string
  end

end