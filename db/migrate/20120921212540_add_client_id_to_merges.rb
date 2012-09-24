class AddClientIdToMerges < ActiveRecord::Migration
  def change
    add_column :merges, :client_id, :string
  end
end
