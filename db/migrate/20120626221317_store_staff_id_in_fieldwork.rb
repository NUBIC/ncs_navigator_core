# -*- coding: utf-8 -*-
class StoreStaffIdInFieldwork < ActiveRecord::Migration
  def up
    add_column :fieldworks, :staff_id, :string
  end

  def down
    remove_column :fieldworks, :staff_id
  end
end
