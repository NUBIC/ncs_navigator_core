class CreateDwellingUnits < ActiveRecord::Migration
  def self.up
    create_table :dwelling_units do |t|

      t.integer :psu_code
      t.integer :duplicate_du_code
      t.integer :missed_du_code
      t.integer :du_type_code
      t.string :du_type_other
      t.integer :du_ineligible_code
      t.integer :du_access_code
      t.text :duid_comment
      t.string :transaction_type

      # TODO: determine how to reference other ncs core models and use uuids
      # t.integer :du_id
      # t.integer :list_id
      # t.integer :tsu_id
      # t.integer :ssu_id

      t.timestamps
    end
  end

  def self.down
    drop_table :dwelling_units
  end
end
