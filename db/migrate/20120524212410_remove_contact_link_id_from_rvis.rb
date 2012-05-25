class RemoveContactLinkIdFromRvis < ActiveRecord::Migration
  def self.up
    remove_column :participant_visit_records, :contact_link_id
    remove_column :participant_visit_consents, :contact_link_id
  end

  def self.down
    add_column :participant_visit_records, :contact_link_id, :integer
    add_column :participant_visit_consents, :contact_link_id, :integer
  end
end
