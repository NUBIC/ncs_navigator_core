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
    
    ### person
    :psu_code                       => "PSU_CL1",
    :prefix_code                    => "NAME_PREFIX_CL1",
    :suffix_code                    => "NAME_SUFFIX_CL1",
    :sex_code                       => "GENDER_CL1",
    :age_range_code                 => "AGE_RANGE_CL1",
    :deceased_code                  => "CONFIRM_TYPE_CL2",
    :ethnic_group_code              => "ETHNICITY_CL1",
    :language_code                  => "LANGUAGE_CL2",
    :marital_status_code            => "MARITAL_STATUS_CL1",
    :preferred_contact_method_code  => "CONTACT_TYPE_CL1",
    :planned_move_code              => "CONFIRM_TYPE_CL1",
    :move_info_code                 => "MOVING_PLAN_CL1",
    :when_move_code                 => "CONFIRM_TYPE_CL4",
    :p_tracing_code                 => "CONFIRM_TYPE_CL2",
    :p_info_source_code             => "INFORMATION_SOURCE_CL4",
    
    
    ### person_race
    # :psu_code               => "PSU_CL1",             # already referenced
    :race_code => "RACE_CL1",
    
    
    ### participant
    # :psu_code               => "PSU_CL1",             # already referenced
    :p_type_code              => "PARTICIPANT_TYPE_CL1",
    :status_info_source_code  => "INFORMATION_SOURCE_CL4",
    :status_info_mode_code    => "CONTACT_TYPE_CL1",
    :enroll_status_code       => "CONFIRM_TYPE_CL2",
    :pid_entry_code           => "STUDY_ENTRY_METHOD_CL1",
    :pid_age_eligibility_code => "AGE_ELIGIBLE_CL2",
    
    
    ### participant_person_link
    # :psu_code               => "PSU_CL1",             # already referenced
    :relationship_code => "PERSON_PARTCPNT_RELTNSHP_CL1",
    :is_active_code    => "CONFIRM_TYPE_CL2",
    
    
    ### dwelling_unit
    # :psu_code               => "PSU_CL1",             # already referenced
    :duplicate_du_code  => "CONFIRM_TYPE_CL2",
    :missed_du_code     => "CONFIRM_TYPE_CL2",
    :du_type_code       => "RESIDENCE_TYPE_CL2",
    :du_ineligible_code => "CONFIRM_TYPE_CL3",
    :du_access_code     => "CONFIRM_TYPE_CL2",
    
    
    ### household_unit
    # :psu_code               => "PSU_CL1",             # already referenced
    :hh_status_code     => "CONFIRM_TYPE_CL2",
    :hh_eligibilty_code => "HOUSEHOLD_ELIGIBILITY_CL2",
    :hh_structure_code  => "RESIDENCE_TYPE_CL2",
    
    
    ### dwelling_household_link
    # :psu_code               => "PSU_CL1",             # already referenced
    # :is_active_code         => "CONFIRM_TYPE_CL2",    # already referenced
    :du_rank_code   => "COMMUNICATION_RANK_CL1",
    
    
    ### household_person_link
    # :psu_code               => "PSU_CL1",             # already referenced
    :is_active => "CONFIRM_TYPE_CL2",
    :hh_rank   => "COMMUNICATION_RANK_CL1"
    
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
