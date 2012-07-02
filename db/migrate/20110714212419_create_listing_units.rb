# -*- coding: utf-8 -*-


class CreateListingUnits < ActiveRecord::Migration
  def self.up
    create_table :listing_units do |t|

      t.integer :psu_code,         :null => false, :limit => 36
      t.binary :list_id,           :null => false
      t.integer :list_line
      t.integer :list_source_code, :null => false
      t.text :list_comment
      t.string :transaction_type,  :limit => 36

      # TODO: determine how to reference these other ncs core models:
      # t.integer :ssu_id
      # t.integer :tsu_id

      t.timestamps
    end
  end

  def self.down
    drop_table :listing_units
  end
end