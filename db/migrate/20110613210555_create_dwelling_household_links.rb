class CreateDwellingHouseholdLinks < ActiveRecord::Migration
  def self.up
    create_table :dwelling_household_links do |t|

      t.integer :psu_code,          :null => false, :limit => 36
      t.binary :hh_du_id,           :null => false
      t.references :dwelling_unit,  :null => false
      t.references :household_unit, :null => false
      t.integer :is_active_code,    :null => false
      t.integer :du_rank_code,      :null => false
      t.string :du_rank_other,      :limit => 255
      t.string :transaction_type,   :limit => 36

      t.timestamps
    end
  end

  def self.down
    drop_table :dwelling_household_links
  end
end
