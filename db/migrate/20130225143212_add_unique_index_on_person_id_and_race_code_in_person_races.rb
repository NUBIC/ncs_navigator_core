class AddUniqueIndexOnPersonIdAndRaceCodeInPersonRaces < ActiveRecord::Migration
  def up
    execute "DELETE FROM person_races USING person_races pr
             WHERE person_races.person_id = pr.person_id
             AND person_races.race_code = pr.race_code
             AND person_races.id > pr.id;"
    add_index :person_races, [:person_id, :race_code], :unique => true
  end

  def down
    drop_table :person_races
  end
end
