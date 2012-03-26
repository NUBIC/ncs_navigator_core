class SetDefaultValueForHighIntensity < ActiveRecord::Migration
  def up
    change_column :participants, :high_intensity, :boolean, :default => false
    execute "UPDATE participants SET high_intensity = 'false' where high_intensity IS NULL"
  end

  def down
  end
end
