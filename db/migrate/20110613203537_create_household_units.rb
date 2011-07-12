class CreateHouseholdUnits < ActiveRecord::Migration
  def self.up
    create_table :household_units do |t|

      t.integer :psu_code,            :null => false, :limit => 36
      t.integer :hh_status_code,      :null => false
      t.integer :hh_eligibility_code,  :null => false
      t.integer :hh_structure_code,   :null => false
      t.string :hh_structure_other,   :limit => 255
      t.text :hh_comment
      t.integer :number_of_age_eligible_women
      t.integer :number_of_pregnant_women
      t.integer :number_of_pregnant_minors
      t.integer :number_of_pregnant_adults
      t.integer :number_of_pregnant_over49
      t.string :transaction_type,     :limit => 36
      
      # TODO: determine how to reference other ncs core models and use uuids
      # t.integer :hh_id

      t.timestamps
    end
  end

  def self.down
    drop_table :household_units
  end
end
