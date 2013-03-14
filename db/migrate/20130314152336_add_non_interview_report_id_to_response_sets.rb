class AddNonInterviewReportIdToResponseSets < ActiveRecord::Migration
  def change
    add_column :response_sets, :non_interview_report_id, :integer
  end
end
