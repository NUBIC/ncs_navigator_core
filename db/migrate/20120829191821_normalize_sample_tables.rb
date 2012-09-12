class NormalizeSampleTables < ActiveRecord::Migration
  def up
    add_column :samples, :sample_shipping_id, :integer, :null => true
    add_foreign_key(:samples, :sample_shippings, :column => 'sample_shipping_id', :name => 'samples_sample_shippings_fk', :options => 'DEFERRABLE')
    
    execute("ALTER TABLE sample_receipt_stores ALTER COLUMN sample_id TYPE integer USING sample_id::int")
    add_foreign_key(:sample_receipt_stores, :samples, :column => 'sample_id', :name => 'sample_receipt_stores_samples_fk', :options => 'DEFERRABLE')
    
    remove_column :sample_shippings, :sample_id
    
    execute("ALTER TABLE sample_receipt_confirmations ALTER COLUMN sample_id TYPE integer USING sample_id::int")
    add_foreign_key(:sample_receipt_confirmations, :samples, :column => 'sample_id', :name => 'sample_receipt_confirmations_samples_fk', :options => 'DEFERRABLE')
    
    rename_column(:sample_receipt_confirmations, :shipment_tracking_number, :sample_shipping_id)
    execute("ALTER TABLE sample_receipt_confirmations ALTER COLUMN sample_shipping_id TYPE integer USING sample_shipping_id::int")
    add_foreign_key(:sample_receipt_confirmations, :sample_shippings, :column => 'sample_shipping_id', :name => 'sample_receipt_confirmations_sample_shippings_fk', :options => 'DEFERRABLE')    
    
    remove_column :sample_shippings, :volume_amount
    remove_column :sample_shippings, :volume_unit
    
    add_column :samples, :volume_amount, :decimal, :precision => 6, :scale => 2
    add_column :samples, :volume_unit, :string, :limit => 36
  end

  def down
    remove_foreign_key(:samples, :name => 'samples_sample_shippings_fk')
     remove_column :samples, :sample_shipping_id
      
     remove_foreign_key(:sample_receipt_stores, :name => 'sample_receipt_stores_samples_fk')
     change_column :sample_receipt_stores, :sample_id, :string
     
     add_column :sample_shippings, :sample_id, :string, :null => false, :limit => 36

     remove_foreign_key(:sample_receipt_confirmations, :name => 'sample_receipt_confirmations_samples_fk')
     change_column :sample_receipt_confirmations, :sample_id, :string

     remove_foreign_key(:sample_receipt_confirmations, :name => 'sample_receipt_confirmations_sample_shippings_fk')
     change_column :sample_receipt_confirmations, :sample_shipping_id, :string
     rename_column(:sample_receipt_confirmations, :sample_shipping_id, :shipment_tracking_number)

     add_column :sample_shippings, :volume_amount, :decimal, :precision => 6, :scale => 2
     add_column :sample_shippings, :volume_unit, :string, :limit => 36
     
     remove_column :samples, :volume_amount
     remove_column :samples, :volume_unit
  end
end


