# -*- coding: utf-8 -*-
class AddContactLinkToRvisAndVisitConsent < ActiveRecord::Migration
  def self.up
    add_column :participant_visit_records, :contact_link_id, :integer
    add_column :participant_visit_consents, :contact_link_id, :integer
  end

  def self.down
    remove_column :participant_visit_consents, :contact_link_id
    remove_column :participant_visit_records, :contact_link_id
  end
end