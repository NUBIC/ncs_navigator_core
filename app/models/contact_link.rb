# == Schema Information
# Schema version: 20110726214159
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

  validates_presence_of :contact
  validates_presence_of :staff_id
  
end
