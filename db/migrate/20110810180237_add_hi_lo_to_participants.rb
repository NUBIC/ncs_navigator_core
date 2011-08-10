class AddHiLoToParticipants < ActiveRecord::Migration
  def self.up
    add_column :participants, :high_intensity, :boolean
  end

  def self.down
    remove_column :participants, :high_intensity
  end
end