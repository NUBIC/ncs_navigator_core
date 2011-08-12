# == Schema Information
# Schema version: 20110805151543
#
# Table name: contact_links
#
#  id               :integer         not null, primary key
#  psu_code         :integer         not null
#  contact_link_id  :binary          not null
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

# Each Contact Link record associates a unique combination 
# of Staff Member, Person, Event, and/or Instrument that occurs during a Contact.  
# There should be at least 1 contact link record for every contact.
class ContactLink < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :contact_link_id
  
  belongs_to :psu, :conditions => "list_name = 'PSU_CL1'", :foreign_key => :psu_code, :class_name => 'NcsCode', :primary_key => :local_code
  
  belongs_to :contact
  belongs_to :person
  belongs_to :event
  belongs_to :instrument
  # belongs_to :provider
  # belongs_to :staff       # references public_id of staff in ncs_staff_portal

  has_one :response_set

  validates_presence_of :contact
  validates_presence_of :staff_id
  
  accepts_nested_attributes_for :contact,    :allow_destroy => true
  accepts_nested_attributes_for :person,     :allow_destroy => true
  accepts_nested_attributes_for :event,      :allow_destroy => true
  accepts_nested_attributes_for :instrument, :allow_destroy => true
  
end
