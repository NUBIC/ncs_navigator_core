class CreateDwellingHouseholdLinks < ActiveRecord::Migration
  def self.up
    create_table :dwelling_household_links do |t|

      t.integer :psu_code
      t.integer :is_active_code
      t.integer :dwelling_unit_id
      t.integer :household_unit_id
      t.integer :du_rank_code
      t.string :du_rank_other
      
      t.string :transaction_type
      
      # TODO: determine how to reference other ncs core models and use uuids
      # t.integer :hh_du_id

      t.timestamps
    end
  end

  def self.down
    drop_table :dwelling_household_links
  end
end
