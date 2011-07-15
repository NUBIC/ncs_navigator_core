# == Schema Information
# Schema version: 20110624163825
#
# Table name: dwelling_household_links
#
#  id                :integer         not null, primary key
#  psu_code          :integer         not null
#  is_active_code    :integer         not null
#  dwelling_unit_id  :integer         not null
#  household_unit_id :integer         not null
#  du_rank_code      :integer         not null
#  du_rank_other     :string(255)
#  transaction_type  :string(36)
#  created_at        :datetime
#  updated_at        :datetime
#

class DwellingHouseholdLink < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :hh_du_id
  
  belongs_to :dwelling_unit
  belongs_to :household_unit
  
  belongs_to :psu,       :conditions => "list_name = 'PSU_CL1'",                :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :psu_code
  belongs_to :is_active, :conditions => "list_name = 'CONFIRM_TYPE_CL2'",       :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :is_active_code
  belongs_to :du_rank,   :conditions => "list_name = 'COMMUNICATION_RANK_CL1'", :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :du_rank_code

end
