# == Schema Information
# Schema version: 20120507183332
#
# Table name: sample_receipt_shipping_centers
#
#  id                                :integer         not null, primary key
#  psu_code                          :integer         not null
#  sample_receipt_shipping_center_id :string(36)      not null
#  transaction_type                  :string(36)
#  created_at                        :datetime
#  updated_at                        :datetime
#

class SampleReceiptShippingCenter < ActiveRecord::Base
  has_one :address
  accepts_nested_attributes_for :address, :allow_destroy => true
  belongs_to :psu, :conditions => "list_name = 'PSU_CL1'", :foreign_key => "psu_code", :class_name => 'NcsCode', :primary_key => :local_code
  
  before_save :set_srsc_id
  
  validates_presence_of :psu_code  
  
  def public_id
    self.sample_receipt_shipping_center_id
  end
  
  def set_srsc_id
    if self.sample_receipt_shipping_center_id.blank?
      self.sample_receipt_shipping_center_id = NcsNavigatorCore.srsc_id
    end
  end  
end
