# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: contact_links
#
#  contact_id       :integer          not null
#  contact_link_id  :string(36)       not null
#  created_at       :datetime
#  event_id         :integer
#  id               :integer          not null, primary key
#  instrument_id    :integer
#  person_id        :integer
#  provider_id      :integer
#  psu_code         :integer          not null
#  staff_id         :string(36)       not null
#  transaction_type :string(255)
#  updated_at       :datetime
#


# Each Contact Link record associates a unique combination
# of Staff Member, Person, Event, and/or Instrument that occurs during a Contact. 
# There should be at least 1 contact link record for every contact.
class ContactLink < ActiveRecord::Base
  include NcsNavigator::Core::Mdes::MdesRecord
  acts_as_mdes_record :public_id_field => :contact_link_id

  ncs_coded_attribute :psu, 'PSU_CL1'

  belongs_to :contact
  belongs_to :person
  belongs_to :event
  belongs_to :instrument, :inverse_of => :contact_link
  belongs_to :provider
  # belongs_to :staff       # references public_id of staff in ncs_staff_portal

  delegate :participant, :to => :event

  # Validating :contact_id instead of :contact prevents a reload of
  # the associated contact object when creating a contact link
  # alone. This provides a huge speedup in the importer; if validating
  # :contact is necessary, we should provide a scoped validation so it
  # can be excluded in the importer context.
  validates_presence_of :contact_id
  validates_presence_of :staff_id

  accepts_nested_attributes_for :contact,    :allow_destroy => true
  accepts_nested_attributes_for :person,     :allow_destroy => true
  accepts_nested_attributes_for :event,      :allow_destroy => true
  accepts_nested_attributes_for :instrument, :allow_destroy => true

  ##
  # A contact link is 'closed' or 'completed' if the disposition of both the event /and/ contact has been set.
  # @return [true, false]
  def closed?
    (contact && contact.closed?) && (event && event.closed?)
  end
  alias completed? closed?
  alias complete? closed?

  def contact_disposition
    return "" if event.blank?
    disp = DispositionMapper.disposition_text(event.event_disposition_category, contact.contact_disposition)
    disp.blank? ? contact.contact_disposition : disp
  end

  def event_disposition
    return "" if event.blank?
    event.event_disposition_text
  end


  comma do
    contact :contact_type => 'Contact Type', :contact_date_date => 'Contact Date'
    contact :contact_start_time => 'Start Time', :contact_end_time => 'End Time'
    person :first_name => 'First Name', :last_name => 'Last Name'
    provider
    contact_disposition
    event :event_type => 'Event Type'
    event_disposition
    event :event_disposition_category => 'Event Disposition Category'
    contact :contact_comment => 'Contact Comment'
    staff_name
  end

  private

  def staff_name
    return "" if staff_id.blank?
    staff_list[staff_id]
  end

  def staff_list
    @staff_list ||= build_staff_list
  end

  def build_staff_list
    users = Aker.authority.find_users
    Hash[users.map{|key| [key.identifiers[:staff_id], key.full_name]}]
  end

end

