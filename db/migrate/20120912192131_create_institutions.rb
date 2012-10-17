class CreateInstitutions < ActiveRecord::Migration
  def change
    create_table :institutions do |t|
      t.string :psu_code,                       :null => false, :limit => 36
      t.string :institute_id,                   :null => false
      t.integer :institute_type_code,           :null => false
      t.string :institute_type_other,           :limit => 255

      t.string :institute_name,                 :limit => 255
      t.integer :institute_relation_code,       :null => false
      t.string :institute_relation_other,       :limit => 255
      t.integer :institute_owner_code,          :null => false
      t.string :institute_owner_other,          :limit => 255
      t.integer :institute_size
      t.integer :institute_unit_code,           :null => false
      t.string :institute_unit_other,           :limit => 255
      t.integer :institute_info_source_code,    :null => false
      t.string :institute_info_source_other,    :limit => 255

      t.date :institute_info_date
      t.date :institute_info_update
      t.text :institute_comment
      t.string :transaction_type,               :limit => 36

      t.timestamps
    end
  end
end
