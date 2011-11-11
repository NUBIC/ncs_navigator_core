class RemoveDirectRelationshipBetweenPersonAndParticipant < ActiveRecord::Migration
  def change
    remove_column :participants, :person_id
  end
end
