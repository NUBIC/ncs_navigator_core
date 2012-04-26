# encoding: utf-8

class CreateDwellingUnits < ActiveRecord::Migration
  def self.up
    create_table :dwelling_units do |t|

      t.integer :psu_code,            :null => false, :limit => 36
      t.integer :duplicate_du_code,   :null => false
      t.integer :missed_du_code,      :null => false
      t.integer :du_type_code,        :null => false
      t.string :du_type_other,        :limit => 255
      t.integer :du_ineligible_code,  :null => false
      t.integer :du_access_code,      :null => false
      t.text :duid_comment
      t.string :transaction_type,     :limit => 36

      t.binary :du_id,                :null => false
      t.references :listing_unit
      # t.references :tsu
      # t.references :ssu

      t.timestamps
    end
  end

  def self.down
    drop_table :dwelling_units
  end
end