class OptimisticLockingForParticipantsAndPersons < ActiveRecord::Migration
  TABLES = %w(participants people addresses telephones emails ppg_details)

  def up
    TABLES.each do |t|
      add_column t, :lock_version, :integer, :default => 0
    end
  end

  def down
    TABLES.each do |t|
      remove_column t, :lock_version
    end
  end
end
