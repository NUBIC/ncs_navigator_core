class RemoveDuplicatePersonRaceRecords < ActiveRecord::Migration
  def up
    execute "DELETE FROM person_races USING person_races pr
             WHERE person_races.person_id = pr.person_id
             AND ((person_races.race_code = pr.race_code
                   AND person_races.race_code <> 5)
                   OR (person_races.race_other = pr.race_other)
                   OR (person_races.race_code = 5
                       AND person_races.race_other IS NULL
                       AND pr.race_other IS NULL))
             AND person_races.id > pr.id;"
  end

  def down
  end
end
