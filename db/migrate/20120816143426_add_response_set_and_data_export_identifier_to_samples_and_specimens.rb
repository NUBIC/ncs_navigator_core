class AddResponseSetAndDataExportIdentifierToSamplesAndSpecimens < ActiveRecord::Migration

  def up
    add_column :samples, :response_set_id, :integer
    add_column :specimens, :response_set_id, :integer
    add_column :samples, :data_export_identifier, :string
    add_column :specimens, :data_export_identifier, :string
  end

  def down
    remove_column :samples, :response_set_id
    remove_column :specimens, :response_set_id
    remove_column :samples, :data_export_identifier
    remove_column :specimens, :data_export_identifier
  end

end
