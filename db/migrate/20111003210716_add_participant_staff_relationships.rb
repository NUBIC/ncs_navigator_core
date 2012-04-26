# encoding: utf-8

class AddParticipantStaffRelationships < ActiveRecord::Migration
  def up
    create_table :participant_staff_relationships do |t|
      t.references :participant
      t.string :staff_id
      t.boolean :primary
    end
    add_index :participant_staff_relationships, :participant_id
  end

  def down
    drop_table :participant_staff_relationships
    # remove_index :participant_staff_relationships, :participant_id
  end
end