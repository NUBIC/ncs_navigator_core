

class AddContactLinkIdToResponseSet < ActiveRecord::Migration
  def self.up
    add_column :response_sets, :contact_link_id, :integer
  end

  def self.down
    # NOOP - contact_link_id has been removed from response_sets
    # remove_column :response_sets, :contact_link_id
  end
end