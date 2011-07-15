class CreateHouseholdPersonLinks < ActiveRecord::Migration
  def self.up
    create_table :household_person_links do |t|

      t.string :psu_code,           :null => false, :limit => 36
      t.integer :person_id,         :null => false
      t.integer :household_unit_id, :null => false
      t.integer :is_active_code,    :null => false
      t.integer :hh_rank_code,      :null => false
      t.string :hh_rank_other,      :limit => 255
      
      t.binary :person_hh_id,       :null => false
      
      t.string :transaction_type,   :limit => 36
      t.timestamps
    end
  end

  def self.down
    drop_table :household_person_links
  end
end
