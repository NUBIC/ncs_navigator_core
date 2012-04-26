# == Schema Information
# Schema version: 20120420163434
#
# Table name: specimen_pickups
#
#  id                                     :integer         not null, primary key
#  psu_code                               :integer         not null
#  specimen_processing_shipping_center_id :integer
#  event_id                               :integer
#  staff_id                               :string(50)      not null
#  specimen_pickup_datetime               :datetime        not null
#  specimen_pickup_comment_code           :integer         not null
#  specimen_pickup_comment_other          :string(255)
#  specimen_transport_temperature         :decimal(6, 2)
#  transaction_type                       :string(36)
#  created_at                             :datetime
#  updated_at                             :datetime
#

class SpecimenPickup < ActiveRecord::Base
  # include MdesRecord

  belongs_to :specimen_processing_shipping_center
  belongs_to :event
  belongs_to :psu, :conditions => "list_name = 'PSU_CL1'", :foreign_key => "psu_code", :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :specimen_pickup_comment
   
  has_many :specimens
  accepts_nested_attributes_for :specimens, :allow_destroy => true
  
  # 
  # ncs_coded_attribute :psu,                      'PSU_CL1'
  # ncs_coded_attribute :specimen_pickup_comment,  'SPECIMEN_STATUS_CL5'

  validates_presence_of :psu_code
  validates_presence_of :staff_id
  validates_presence_of :specimen_pickup_datetime

  validate :specimen_exists
  
  def specimen_exists
    self.specimens.count > 0
  end
end
