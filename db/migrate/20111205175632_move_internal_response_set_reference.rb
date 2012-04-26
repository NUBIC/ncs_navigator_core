# encoding: utf-8

class MoveInternalResponseSetReference < ActiveRecord::Migration
  def up
    add_column :response_sets, :instrument_id, :integer

    ResponseSet.all.each do |rs|
      if contact_link = ContactLink.find(rs.contact_link_id)
        rs.instrument_id = contact_link.instrument_id
      end
      rs.save!
    end

    remove_column :response_sets, :contact_link_id
  end

  def down
    # NOOP
  end
end