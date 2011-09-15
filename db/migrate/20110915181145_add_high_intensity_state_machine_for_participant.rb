class AddHighIntensityStateMachineForParticipant < ActiveRecord::Migration
  def up
    rename_column :participants, :state, :low_intensity_state
    add_column :participants, :high_intensity_state, :string
  end

  def down
  end
end