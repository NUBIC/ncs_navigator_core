class AddStateToParticipants < ActiveRecord::Migration
  def change
    add_column :participants, :state, :string
  end
end
