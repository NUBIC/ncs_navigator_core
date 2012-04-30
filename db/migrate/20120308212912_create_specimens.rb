class CreateSpecimens < ActiveRecord::Migration
  def up
    create_table :specimens do |s|
      s.string :specimen_id, :null => false, :limit => 36
      s.references :specimen_pickup
      s.references :instrument
      s.timestamps
    end
  end
  
  def down
    drop_table :specimens
  end
end
