# == Schema Information
# Schema version: 20110624163825
#
# Table name: ncs_codes
#
#  id               :integer         not null, primary key
#  list_name        :string(255)
#  list_description :string(255)
#  display_text     :string(255)
#  local_code       :integer
#  global_code      :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#

class NcsCode < ActiveRecord::Base
  validates_presence_of :list_name, :display_text, :local_code
  
  ATTRIBUTE_MAPPING = { 
    
    ### dwelling_unit
    :psu_code           => "PSU_CL1",
    :duplicate_du_code  => "CONFIRM_TYPE_CL2",
    :missed_du_code     => "CONFIRM_TYPE_CL2",
    :du_type_code       => "RESIDENCE_TYPE_CL2",
    :du_ineligible_code => "CONFIRM_TYPE_CL3",
    :du_access_code     => "CONFIRM_TYPE_CL2",
    
    ### household_unit
    # :psu_code           => "PSU_CL1",         # already referenced
    :hh_status_code     => "CONFIRM_TYPE_CL2",
    :hh_eligibilty_code => "HOUSEHOLD_ELIGIBILITY_CL2",
    :hh_structure_code  => "RESIDENCE_TYPE_CL2",
    
    ### dwelling_household_link
    # :psu_code           => "PSU_CL1",         # already referenced
    :is_active_code => "CONFIRM_TYPE_CL2",
    :du_rank_code   => "COMMUNICATION_RANK_CL1"
    
  }

  def self.ncs_code_lookup(attribute_name)
    list_name = attribute_lookup(attribute_name)
    NcsCode.find_all_by_list_name(list_name).map do |n| 
      [n.display_text, n.local_code]
    end    
  end
  
  def self.attribute_lookup(attribute_name)
     ATTRIBUTE_MAPPING[attribute_name]
  end
  
  def to_s
    display_text
  end
  
  def code
    local_code
  end
end
