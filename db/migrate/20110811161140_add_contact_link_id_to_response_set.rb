class AddContactLinkIdToResponseSet < ActiveRecord::Migration
  def self.up
    add_column :response_sets, :contact_link_id, :integer
  end

  def self.down
    remove_column :response_sets, :contact_link_id
  end
end