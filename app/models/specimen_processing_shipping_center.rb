# == Schema Information
# Schema version: 20120507183332
#
# Table name: specimen_processing_shipping_centers
#
#  id                                     :integer         not null, primary key
#  psu_code                               :integer         not null
#  specimen_processing_shipping_center_id :string(36)      not null
#  transaction_type                       :string(36)
#  created_at                             :datetime
#  updated_at                             :datetime
#

class SpecimenProcessingShippingCenter < ActiveRecord::Base
  has_one :address
  accepts_nested_attributes_for :address, :allow_destroy => true
  belongs_to :psu, :conditions => "list_name = 'PSU_CL1'", :foreign_key => "psu_code", :class_name => 'NcsCode', :primary_key => :local_code
  
  before_save :set_spsc_id
  
  validates_presence_of :psu_code
  
  def public_id
    self.specimen_processing_shipping_center_id
  end
  
  def set_spsc_id
    if self.specimen_processing_shipping_center_id.blank?
      self.specimen_processing_shipping_center_id = NcsNavigatorCore.spsc_id
    end
  end
  
end