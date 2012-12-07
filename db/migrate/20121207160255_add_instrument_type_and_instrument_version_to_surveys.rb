# encoding: UTF-8
class AddInstrumentTypeAndInstrumentVersionToSurveys < ActiveRecord::Migration
  def self.up
    add_column :surveys, :instrument_version, :string, :limit => 36
    add_column :surveys, :instrument_type, :integer
  end

  def self.down
    remove_column :surveys, :instrument_version
    remove_column :surveys, :instrument_type
  end
end
