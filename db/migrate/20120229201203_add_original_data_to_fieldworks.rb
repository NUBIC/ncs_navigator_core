# encoding: utf-8

class AddOriginalDataToFieldworks < ActiveRecord::Migration
  def change
    add_column :fieldworks, :original_data, :binary
  end
end