class ChangeDefaultValueForParticipantsBeingFollowedToTrue < ActiveRecord::Migration
  def up
    change_column_default(:participants, :being_followed, true)
  end

  def down
    change_column_default(:participants, :being_followed, false)
  end
end
