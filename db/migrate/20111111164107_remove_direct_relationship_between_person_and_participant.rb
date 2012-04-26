# -*- coding: utf-8 -*-

class RemoveDirectRelationshipBetweenPersonAndParticipant < ActiveRecord::Migration
  def up
    remove_column :participants, :person_id
  end

  def down
    # NOOP
  end
end