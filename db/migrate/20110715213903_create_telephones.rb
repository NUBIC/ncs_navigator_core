# -*- coding: utf-8 -*-


class CreateTelephones < ActiveRecord::Migration
  def self.up
    create_table :telephones do |t|
      t.integer :psu_code,                :null => false, :limit => 36
      t.binary :phone_id,                 :null => false
      t.references :person
      # t.references institute
      # t.references provider
      t.integer :phone_info_source_code,  :null => false
      t.string :phone_info_source_other
      t.date :phone_info_date
      t.date :phone_info_update
      t.string :phone_nbr,                :limit => 10
      t.string :phone_ext,                :limit => 5
      t.integer :phone_type_code,         :null => false
      t.string :phone_type_other
      t.integer :phone_rank_code,         :null => false
      t.string :phone_rank_other
      t.integer :phone_landline_code,     :null => false
      t.integer :phone_share_code,        :null => false
      t.integer :cell_permission_code,    :null => false
      t.integer :text_permission_code,    :null => false
      t.text :phone_comment
      t.string :phone_start_date,         :limit => 10
      t.date :phone_start_date_date
      t.string :phone_end_date,           :limit => 10
      t.date :phone_end_date_date
      t.string :transaction_type

      t.timestamps
    end
  end

  def self.down
    drop_table :telephones
  end
end