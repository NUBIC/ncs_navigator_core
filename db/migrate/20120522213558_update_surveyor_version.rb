class UpdateSurveyorVersion < ActiveRecord::Migration
  def self.up
    rename_column :surveys, :version, :survey_version
    add_index(:surveys, [ :access_code, :survey_version], :name => 'surveys_access_code_version_idx', :unique => true)
  end

  def self.down
    rename_column :surveys, :survey_version, :version
    remove_index( :surveys, :name => 'surveys_access_code_version_idx' )
  end
end