class AddUniqueIndexOnPersonIdAndInstitutionIdInInstitutionPersonLinks < ActiveRecord::Migration
  def up
    execute "DELETE FROM institution_person_links USING institution_person_links ipl
             WHERE institution_person_links.person_id = ipl.person_id
             AND institution_person_links.institution_id = ipl.institution_id
             AND institution_person_links.id > ipl.id;"
    add_index :institution_person_links, [:institution_id, :person_id], :unique => true
  end

  def down
    drop_table :institution_person_links
  end
end
