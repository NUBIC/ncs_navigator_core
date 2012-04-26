class CreateSpecimenPickups < ActiveRecord::Migration
  def up
    create_table :specimen_pickups do |t|
      t.integer :psu_code,                       :null => false
      t.references :specimen_processing_shipping_center
      t.references :event
      t.string :staff_id,                        :null => false, :limit => 50
      t.datetime :specimen_pickup_datetime,      :null => false
      t.integer :specimen_pickup_comment_code,   :null => false
      t.string :specimen_pickup_comment_other,   :limit => 255
      t.decimal :specimen_transport_temperature, :precision => 6, :scale => 2
      t.string :transaction_type,                :limit => 36
      t.timestamps
    end
  end

  def down
    drop_table :specimen_pickups
  end
end
