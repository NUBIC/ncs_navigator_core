class AddImportedInvalidToEvents < ActiveRecord::Migration
  def change
  	add_column :events, :imported_invalid, :boolean, :null => false, :default => false
  end
end
