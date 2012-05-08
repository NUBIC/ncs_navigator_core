class AddVolumeToSampleShipping < ActiveRecord::Migration
  def up
    add_column :sample_shippings, :volume_amount, :decimal, :precision => 6, :scale => 2
    add_column :sample_shippings, :volume_unit, :string, :limit => 36
  end

  def down
    remove_column :sample_shippings, :volume_amount
    remove_column :sample_shippings, :volume_unit
  end
end
