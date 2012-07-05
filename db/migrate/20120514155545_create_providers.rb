# -*- coding: utf-8 -*-
class CreateProviders < ActiveRecord::Migration
  def self.up
    create_table :providers do |t|

      t.integer :psu_code,                    :null => false
      t.string :provider_id,                  :null => false, :limit => 36
      t.integer :provider_type_code,          :null => false
      t.string :provider_type_other
      t.integer :provider_ncs_role_code,      :null => false
      t.string :provider_ncs_role_other
      t.integer :practice_info_code,          :null => false
      t.integer :practice_patient_load_code,  :null => false
      t.integer :practice_size_code,          :null => false
      t.integer :public_practice_code,        :null => false
      t.integer :provider_info_source_code,   :null => false
      t.string :provider_info_source_other
      t.date :provider_info_date
      t.date :provider_info_update
      t.text :provider_comment
      t.string :transaction_type

      t.timestamps
    end

    add_column :addresses, :provider_id, :integer
  end

  def self.down
    remove_column :addresses, :provider_id
    drop_table :providers
  end
end