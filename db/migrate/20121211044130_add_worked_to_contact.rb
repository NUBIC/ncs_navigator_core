class AddWorkedToContact < ActiveRecord::Migration
  def change
    add_column :contacts, :worked, :boolean, :default => true, :null => false
    add_index :contacts, :worked
  end
end
