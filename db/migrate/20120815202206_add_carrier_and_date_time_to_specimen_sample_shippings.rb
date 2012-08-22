class AddCarrierAndDateTimeToSpecimenSampleShippings < ActiveRecord::Migration
  def up
    add_column :sample_shippings, :carrier, :string
    add_column :sample_shippings, :shipment_time, :string, :limit => 5
    add_column :specimen_shippings, :carrier, :string
    add_column :specimen_shippings, :shipment_time, :string, :limit => 5
  end

  def down
    remove_column :sample_shippings, :carrier
    remove_column :sample_shippings, :shipment_time
    remove_column :specimen_shippings, :carrier
    remove_column :specimen_shippings, :shipment_time
  end
end
