class AddMultiBirthIdToParticipantPersonLink < ActiveRecord::Migration
  def change
  	add_column :participant_person_links, :multi_birth_id, :string, :limit => 36, :null => true
  end
end
