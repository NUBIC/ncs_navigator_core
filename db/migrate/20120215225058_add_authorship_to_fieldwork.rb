# -*- coding: utf-8 -*-


class AddAuthorshipToFieldwork < ActiveRecord::Migration
  def up
    add_column :fieldworks, :client_id, :string
    add_column :fieldworks, :end_date, :date
    add_column :fieldworks, :start_date, :date
  end

  def down
    remove_column :fieldworks, :start_date
    remove_column :fieldworks, :end_date
    remove_column :fieldworks, :client_id
  end
end