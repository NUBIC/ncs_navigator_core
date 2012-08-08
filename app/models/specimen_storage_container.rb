class SpecimenReceipt < ActiveRecord::Base
  has_one :specimen_receipt
  has_one :specimen_storage
  belongs_to :specimen_shipping
end