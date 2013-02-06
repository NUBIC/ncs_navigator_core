# == Schema Information
# Schema version: 20130131234657
#
# Table name: event_type_order
#
#  event_type_code :integer          not null
#  id              :integer          not null, primary key
#

##
# == Schema Information
# Schema version: 20130131234657
#
# Table name: event_type_order
#
#  event_type_code :integer          not null
#  id              :integer          not null, primary key
#
#
# This is a helper for {Event.chronological}.  It's used during Cases
# initialization to get {Event::TYPE_ORDER} in a form that can be used in ORDER
# BY clauses.
#
# You shouldn't be using this for any other purpose.
#
# @private
class EventTypeOrder < ActiveRecord::Base
  set_table_name 'event_type_order'

  def self.persist_if_different
    begin
      persist if different?
    rescue ActiveRecord::StatementInvalid => e
      Rails.logger.warn("#{name} prepopulation failed: #{e.message}.  Is the database schema up to date?")
    end
  end

  def self.different?
    res = select("string_agg(event_type_code::text, ',' ORDER BY id) AS all").first

    res.all != Event::TYPE_ORDER.join(',')
  end

  def self.persist
    transaction do
      delete_all

      Event::TYPE_ORDER.each { |tc| create(:event_type_code => tc) }
    end
  end
end
