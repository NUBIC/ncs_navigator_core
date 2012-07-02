

class AddEnrollmentStatusCommentToParticipant < ActiveRecord::Migration
  def change
    add_column :participants, :enrollment_status_comment, :text
  end
end