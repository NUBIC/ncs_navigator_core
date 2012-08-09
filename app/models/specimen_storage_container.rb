class SpecimenStorageContainer < ActiveRecord::Base
  has_one :specimen_receipt
  accepts_nested_attributes_for :specimen_receipt, :allow_destroy => true
  
  has_one :specimen_storage
  belongs_to :specimen_shipping
  
  validates_presence_of :storage_container_id
end