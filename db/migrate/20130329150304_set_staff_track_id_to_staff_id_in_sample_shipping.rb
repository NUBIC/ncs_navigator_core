class SetStaffTrackIdToStaffIdInSampleShipping < ActiveRecord::Migration
  def up
    execute("UPDATE sample_shippings SET staff_id_track=staff_id")
    change_column :sample_shippings, :staff_id_track, :string, :limit => 36, :null => false
  end

  def down
    change_column :sample_shippings, :staff_id_track, :string, :limit => 36, :null => true
  end
end
