class CreateShipSpecimen < ActiveRecord::Migration
  def up
    create_table :ship_specimens do |s|
      s.references :specimen
      s.references :specimen_shipping
      s.decimal :volume_amount,         :precision => 6, :scale => 2
      s.string :volume_unit,            :limit => 36
      s.timestamps
    end
  end

  def down
    drop_table :ship_specimens
  end
end
