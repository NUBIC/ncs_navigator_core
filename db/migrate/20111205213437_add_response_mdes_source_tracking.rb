# -*- coding: utf-8 -*-


class AddResponseMdesSourceTracking < ActiveRecord::Migration
  def up
    add_column :responses, :source_mdes_table, :string, :limit => 100
    add_column :responses, :source_mdes_id, :string, :limit => 36
  end

  def down
    remove_column :responses, :source_mdes_table
    remove_column :responses, :source_mdes_id
  end
end