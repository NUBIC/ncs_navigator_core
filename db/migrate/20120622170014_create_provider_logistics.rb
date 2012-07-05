# -*- coding: utf-8 -*-
class CreateProviderLogistics < ActiveRecord::Migration
  def change
    create_table :provider_logistics do |t|
      t.integer :psu_code,                    :null => false
      t.string :provider_logistics_id,        :null => false, :limit => 36
      t.integer :provider_id
      t.integer :provider_logistics_code,     :null => false
      t.string :provider_logistics_other

      t.string :transaction_type

      t.timestamps
    end
  end
end
