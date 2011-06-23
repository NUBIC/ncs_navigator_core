class CreatePersonRaces < ActiveRecord::Migration
  def self.up
    create_table :person_races do |t|

      t.string :psu_code,         :null => false, :limit => 36
      t.integer :person_id,       :null => false
      t.integer :race_code,       :null => false
      t.string :race_other,       :limit => 255
      t.string :transaction_type, :limit => 36

      # TODO: determine how to reference other ncs core models and use uuids
      # t.integer :person_race_id

      t.timestamps
    end
  end

  def self.down
    drop_table :person_races
  end
end
