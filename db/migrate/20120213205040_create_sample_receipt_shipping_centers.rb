# -*- coding: utf-8 -*-
class CreateSampleReceiptShippingCenters < ActiveRecord::Migration
  def up
      create_table :sample_receipt_shipping_centers do |t|
        t.integer :psu_code,                                :null => false
        t.string :sample_receipt_shipping_center_id,        :null => false, :limit => 36
        t.string :transaction_type,                         :limit => 36
        t.timestamps
      end
    end

    def down
      drop_table :sample_receipt_shipping_centers
    end
end
