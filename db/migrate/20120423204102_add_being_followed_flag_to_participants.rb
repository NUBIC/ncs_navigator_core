# -*- coding: utf-8 -*-


class AddBeingFollowedFlagToParticipants < ActiveRecord::Migration
  def self.up
    add_column :participants, :being_followed, :boolean, :default => false
    Participant.all.each { |p| p.update_attribute(:being_followed, true) if p.enrolled? }
  end

  def self.down
    remove_column :participants, :being_followed
  end
end