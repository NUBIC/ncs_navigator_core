# == Schema Information
# Schema version: 20110613210555
#
# Table name: dwelling_household_links
#
#  id                :integer         not null, primary key
#  psu_code          :integer
#  is_active_code    :integer
#  dwelling_unit_id  :integer
#  household_unit_id :integer
#  du_rank_code      :integer
#  du_rank_other     :string(255)
#  transaction_type  :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#

class DwellingHouseholdLink < ActiveRecord::Base
  
  belongs_to :dwelling_unit
  belongs_to :household_unit
  
  belongs_to :psu,       :conditions => "list_name = 'PSU_CL1'",                :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :psu_code
  belongs_to :is_active, :conditions => "list_name = 'CONFIRM_TYPE_CL2'",       :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :is_active_code
  belongs_to :du_rank,   :conditions => "list_name = 'COMMUNICATION_RANK_CL1'", :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :du_rank_code
  
end
