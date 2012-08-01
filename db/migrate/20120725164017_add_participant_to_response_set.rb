class AddParticipantToResponseSet < ActiveRecord::Migration
  def change
    add_column :response_sets, :participant_id, :integer
  end
end