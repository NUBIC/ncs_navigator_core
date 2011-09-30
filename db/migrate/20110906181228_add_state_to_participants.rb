class AddStateToParticipants < ActiveRecord::Migration
  def up
    add_column :participants, :state, :string
  end
end
