# == Schema Information
# Schema version: 20110624163825
#
# Table name: household_person_links
#
#  id                :integer         not null, primary key
#  psu_code          :string(36)      not null
#  person_id         :integer         not null
#  household_unit_id :integer         not null
#  is_active_code    :integer         not null
#  hh_rank_code      :integer         not null
#  hh_rank_other     :string(255)
#  transaction_type  :string(36)
#  created_at        :datetime
#  updated_at        :datetime
#

class HouseholdPersonLink < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :person_hh_id
  
  belongs_to :person
  belongs_to :household_unit
  
  belongs_to :psu,       :conditions => "list_name = 'PSU_CL1'",                :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :psu_code
  belongs_to :is_active, :conditions => "list_name = 'CONFIRM_TYPE_CL2'",       :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :is_active_code
  belongs_to :hh_rank,   :conditions => "list_name = 'COMMUNICATION_RANK_CL1'", :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :hh_rank_code
  
  validates_presence_of :person
  validates_presence_of :household_unit  
end
