# -*- coding: utf-8 -*-
class AddContactInfoForSampleSpecimenShippingTables < ActiveRecord::Migration
  def up
    add_column :sample_shippings, :contact_name, :string
    add_column :sample_shippings, :contact_phone, :string, :limit => 30
    
    add_column :specimen_shippings, :contact_name, :string
    add_column :specimen_shippings, :contact_phone, :string, :limit => 30
  end

  def down
    remove_column :sample_shippings, :contact_name
    remove_column :sample_shippings, :contact_phone

    remove_column :specimen_shippings, :contact_name
    remove_column :specimen_shippings, :contact_phone
  end
end
