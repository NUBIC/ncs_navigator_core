# encoding: utf-8

class CreateNcsCodes < ActiveRecord::Migration
  def self.up
    create_table :ncs_codes do |t|
      t.string :list_name
      t.string :list_description
      t.string :display_text
      t.integer :local_code
      t.string :global_code

      t.timestamps
    end

  end

  def self.down
    drop_table :ncs_codes
  end
end