

class AddBeingProcessedToMdesRecords < ActiveRecord::Migration
  def self.up
    add_column :listing_units,   :being_processed, :boolean, :default => false
    add_column :household_units, :being_processed, :boolean, :default => false
    add_column :dwelling_units,  :being_processed, :boolean, :default => false
    add_column :people,          :being_processed, :boolean, :default => false
    add_column :participants,    :being_processed, :boolean, :default => false
  end

  def self.down
    remove_column :participants,    :being_processed
    remove_column :people,          :being_processed
    remove_column :dwelling_units,  :being_processed
    remove_column :household_units, :being_processed
    remove_column :listing_units,   :being_processed
  end
end