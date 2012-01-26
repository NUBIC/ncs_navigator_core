# == Schema Information
# Schema version: 20120120165946
#
# Table name: contact_links
#
#  id               :integer         not null, primary key
#  psu_code         :integer         not null
#  contact_link_id  :string(36)      not null
#  contact_id       :integer         not null
#  event_id         :integer
#  instrument_id    :integer
#  staff_id         :string(36)      not null
#  person_id        :integer
#  provider_id      :integer
#  transaction_type :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#

# -*- coding: utf-8 -*-
# Each Contact Link record associates a unique combination
# of Staff Member, Person, Event, and/or Instrument that occurs during a Contact. 
# There should be at least 1 contact link record for every contact.
class ContactLink < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :contact_link_id

  ncs_coded_attribute :psu, 'PSU_CL1'

  belongs_to :contact
  belongs_to :person
  belongs_to :event
  belongs_to :instrument
  # belongs_to :provider
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

end
