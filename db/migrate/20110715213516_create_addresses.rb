# -*- coding: utf-8 -*-

class CreateAddresses < ActiveRecord::Migration
  def self.up
    create_table :addresses do |t|

      t.integer :psu_code,                  :null => false, :limit => 36
      t.binary :address_id,                 :null => false
      t.references :person
      # t.references institute
      # t.references provider
      t.references :dwelling_unit,          :null => false
      t.integer :address_rank_code,         :null => false
      t.string :address_rank_other
      t.integer :address_info_source_code,  :null => false
      t.string :address_info_source_other
      t.integer :address_info_mode_code,    :null => false
      t.string :address_info_mode_other
      t.date :address_info_date
      t.date :address_info_update
      t.string :address_start_date,         :limit => 10
      t.date :address_start_date_date
      t.string :address_end_date,           :limit => 10
      t.date :address_end_date_date
      t.integer :address_type_code,         :null => false
      t.string :address_type_other
      t.integer :address_description_code, :null => false
      t.string :address_description_other
      t.string :address_one,              :limit => 100
      t.string :address_two,              :limit => 100
      t.string :unit,                     :limit => 10
      t.string :city,                     :limit => 50
      t.integer :state_code,              :null => false
      t.string :zip,                      :limit => 5
      t.string :zip4,                     :limit => 4
      t.text :address_comment
      t.string :transaction_type

      t.timestamps
    end
  end

  def self.down
    drop_table :addresses
  end
end