class AddUsernameToMerge < ActiveRecord::Migration
  def change
    add_column :merges, :username, :string, :null => false
  end
end
