# == Schema Information
# Schema version: 20120515181518
#
# Table name: sample_receipt_shipping_centers
#
#  id                                :integer         not null, primary key
#  psu_code                          :integer         not null
#  sample_receipt_shipping_center_id :string(36)      not null
#  transaction_type                  :string(36)
#  created_at                        :datetime
#  updated_at                        :datetime
#  address_id                        :integer
#

class SampleReceiptShippingCenter < ActiveRecord::Base
  belongs_to :address
  accepts_nested_attributes_for :address, :allow_destroy => true
  belongs_to :psu, :conditions => "list_name = 'PSU_CL1'", :foreign_key => "psu_code", :class_name => 'NcsCode', :primary_key => :local_code
  
  validates_presence_of :psu_code
  validates_presence_of :sample_receipt_shipping_center_id
end
