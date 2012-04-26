# encoding: utf-8

class CreateFieldworks < ActiveRecord::Migration
  def change
    create_table :fieldworks, :id => false do |t|
      t.string :fieldwork_id, :limit => 36
      t.binary :received_data
      t.timestamps
    end

    add_index :fieldworks, :fieldwork_id, :unique => true
  end
end