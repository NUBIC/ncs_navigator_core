# == Schema Information
# Schema version: 20110715213911
#
# Table name: listing_units
#
#  id               :integer         not null, primary key
#  psu_code         :integer         not null
#  list_id          :binary          not null
#  list_line        :integer
#  list_source_code :integer         not null
#  list_comment     :text
#  transaction_type :string(36)
#  created_at       :datetime
#  updated_at       :datetime
#

class ListingUnit < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :list_id

  belongs_to :psu,           :conditions => "list_name = 'PSU_CL1'",            :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :psu_code
  belongs_to :list_source,   :conditions => "list_name = 'LISTING_SOURCE_CL1'", :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :list_source_code

  has_one :dwelling_unit

end
