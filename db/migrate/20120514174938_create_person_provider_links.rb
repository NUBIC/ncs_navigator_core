# -*- coding: utf-8 -*-
class CreatePersonProviderLinks < ActiveRecord::Migration
  def self.up
    create_table :person_provider_links do |t|

      t.integer :psu_code,                    :null => false
      t.string :person_provider_id,           :null => false, :limit => 36
      t.references :provider
      t.references :person
      t.integer :is_active_code,              :null => false
      t.integer :provider_intro_outcome_code, :null => false
      t.string :provider_intro_outcome_other
      t.string :transaction_type,             :limit => 36

      t.timestamps
    end
  end

  def self.down
    drop_table :person_provider_links
  end
end
