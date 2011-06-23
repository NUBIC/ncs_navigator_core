class CreateDwellingHouseholdLinks < ActiveRecord::Migration
  def self.up
    create_table :dwelling_household_links do |t|

      t.integer :psu_code,          :null => false, :limit => 36
      t.integer :is_active_code,    :null => false
      t.integer :dwelling_unit_id,  :null => false
      t.integer :household_unit_id, :null => false
      t.integer :du_rank_code,      :null => false
      t.string :du_rank_other,      :limit => 255
      t.string :transaction_type,   :limit => 36
      
      # TODO: determine how to reference other ncs core models and use uuids
      # t.integer :hh_du_id

      t.timestamps
    end
  end

  def self.down
    drop_table :dwelling_household_links
  end
end
