# == Schema Information
# Schema version: 20110624163825
#
# Table name: participants
#
#  id                       :integer         not null, primary key
#  psu_code                 :string(36)      not null
#  person_id                :integer         not null
#  p_type_code              :integer         not null
#  p_type_other             :string(255)
#  status_info_source_code  :integer         not null
#  status_info_source_other :string(255)
#  status_info_mode_code    :integer         not null
#  status_info_mode_other   :string(255)
#  status_info_date         :date
#  enroll_status_code       :integer         not null
#  enroll_date              :date
#  pid_entry_code           :integer         not null
#  pid_entry_other          :string(255)
#  pid_age_eligibility_code :integer         not null
#  pid_comment              :text
#  transaction_type         :string(36)
#  created_at               :datetime
#  updated_at               :datetime
#

class Participant < ActiveRecord::Base

  belongs_to :person
  belongs_to :psu,                  :conditions => "list_name = 'PSU_CL1'",                 :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :psu_code
  belongs_to :p_type,               :conditions => "list_name = 'PARTICIPANT_TYPE_CL1'",    :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :p_type_code
  belongs_to :status_info_source,   :conditions => "list_name = 'INFORMATION_SOURCE_CL4'",  :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :status_info_source_code
  belongs_to :status_info_mode,     :conditions => "list_name = 'CONTACT_TYPE_CL1'",        :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :status_info_mode_code
  belongs_to :enroll_status,        :conditions => "list_name = 'CONFIRM_TYPE_CL2'",        :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :enroll_status_code
  belongs_to :pid_entry,            :conditions => "list_name = 'STUDY_ENTRY_METHOD_CL1'",  :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :pid_entry_code
  belongs_to :pid_age_eligibility,  :conditions => "list_name = 'AGE_ELIGIBLE_CL2'",        :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :pid_age_eligibility_code
  
  validates_presence_of :person
  validates_presence_of :psu
  validates_presence_of :p_type
  validates_presence_of :status_info_source
  validates_presence_of :status_info_mode
  validates_presence_of :enroll_status
  validates_presence_of :pid_entry
  validates_presence_of :pid_age_eligibility
  
end
