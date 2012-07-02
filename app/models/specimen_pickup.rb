class SpecimenPickup < ActiveRecord::Base
  # include MdesRecord

  belongs_to :specimen_processing_shipping_center
  belongs_to :event
  belongs_to :psu, :conditions => "list_name = 'PSU_CL1'", :foreign_key => "psu_code", :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :specimen_pickup_comment
   
  has_many :specimens
  accepts_nested_attributes_for :specimens, :allow_destroy => true
  
  validates_presence_of :psu_code
  validates_presence_of :staff_id
  validates_presence_of :specimen_pickup_datetime

  validate :specimen_exists
  
  def specimen_exists
    self.specimens.count > 0
  end
end

