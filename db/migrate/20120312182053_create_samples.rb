class CreateSamples < ActiveRecord::Migration
  def up
    create_table :samples do |s|
      s.string :sample_id,                     :null => false, :limit => 36
      s.references :instrument
      s.timestamps
    end
  end
  
  def down
    drop_table :samples
  end
end


