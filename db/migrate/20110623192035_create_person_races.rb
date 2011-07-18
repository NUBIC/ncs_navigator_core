class CreatePersonRaces < ActiveRecord::Migration
  def self.up
    create_table :person_races do |t|

      t.string :psu_code,         :null => false, :limit => 36
      t.binary :person_race_id,   :null => false
      t.references :person,       :null => false
      t.integer :race_code,       :null => false
      t.string :race_other,       :limit => 255
      t.string :transaction_type, :limit => 36


      t.timestamps
    end
  end

  def self.down
    drop_table :person_races
  end
end
