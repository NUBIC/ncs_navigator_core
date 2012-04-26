# == Schema Information
# Schema version: 20120420163434
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
  include MdesRecord
  acts_as_mdes_record :public_id_field => :specimen_processing_shipping_center_id

  has_one :address
  accepts_nested_attributes_for :address, :allow_destroy => true
  ncs_coded_attribute :psu, 'PSU_CL1'
end
