# -*- coding: utf-8 -*-
class AddShippingCentersIdsToAddress < ActiveRecord::Migration
  def up
    add_column :addresses, :specimen_processing_shipping_center_id, :integer, :null => true
    add_column :addresses, :sample_receipt_shipping_center_id, :integer, :null => true
  end

  def down
    remove_column :addresses, :specimen_processing_shipping_center_id
    remove_column :addresses, :sample_receipt_shipping_center_id
  end
end
