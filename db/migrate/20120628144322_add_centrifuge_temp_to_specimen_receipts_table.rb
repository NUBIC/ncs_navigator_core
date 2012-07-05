# -*- coding: utf-8 -*-
class AddCentrifugeTempToSpecimenReceiptsTable < ActiveRecord::Migration
  def up  
    add_column :specimen_receipts, :centrifuge_temp, :decimal, :precision => 6, :scale => 2
  end
  def down
    remove_column :specimen_receipts, :centrifuge_temp
  end
end
