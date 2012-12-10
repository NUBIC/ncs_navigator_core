class CreateInstitutionPersonLinks < ActiveRecord::Migration
  def change
    create_table :institution_person_links do |t|
      t.string :psu_code,                 :null => false, :limit => 36
      t.string :person_institute_id,      :null => false, :limit => 36
      t.references :person,               :null => false
      t.references :institution,          :null => false
      t.integer :is_active_code,          :null => false
      t.integer :institute_relation_code, :null => false
      t.string :institute_relation_other, :limit => 255

      t.string :transaction_type,         :limit => 36
      t.timestamps
    end
  end
end
