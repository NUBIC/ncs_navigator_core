class UpdateSurveyorVersion < ActiveRecord::Migration
  def self.up
    change_column :surveys, :survey_version, :integer, :default => 0
    add_index(:surveys, [ :access_code, :survey_version], :name => 'surveys_access_code_version_idx', :unique => true)
  end

  def self.down
    change_column :surveys, :survey_version, :integer
    remove_index( :surveys, :name => 'surveys_access_code_version_idx' )
  end
end