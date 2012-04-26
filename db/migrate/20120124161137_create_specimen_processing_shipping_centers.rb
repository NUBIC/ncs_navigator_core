class CreateSpecimenProcessingShippingCenters < ActiveRecord::Migration
  def up
      create_table :specimen_processing_shipping_centers do |t|
        t.integer :psu_code,                                :null => false
        t.string :specimen_processing_shipping_center_id,   :null => false, :limit => 36
        t.string :transaction_type,                         :limit => 36
        t.timestamps
      end
    end

    def down
      drop_table :specimen_processing_shipping_centers
    end
end
