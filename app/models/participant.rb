# == Schema Information
# Schema version: 20110715213911
#
# Table name: participants
#
#  id                       :integer         not null, primary key
#  psu_code                 :string(36)      not null
#  p_id                     :binary          not null
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
  include MdesRecord
  acts_as_mdes_record :public_id_field => :p_id

  belongs_to :person
  belongs_to :psu,                  :conditions => "list_name = 'PSU_CL1'",                 :foreign_key => :psu_code,                  :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :p_type,               :conditions => "list_name = 'PARTICIPANT_TYPE_CL1'",    :foreign_key => :p_type_code,               :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :status_info_source,   :conditions => "list_name = 'INFORMATION_SOURCE_CL4'",  :foreign_key => :status_info_source_code,   :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :status_info_mode,     :conditions => "list_name = 'CONTACT_TYPE_CL1'",        :foreign_key => :status_info_mode_code,     :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :enroll_status,        :conditions => "list_name = 'CONFIRM_TYPE_CL2'",        :foreign_key => :enroll_status_code,        :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :pid_entry,            :conditions => "list_name = 'STUDY_ENTRY_METHOD_CL1'",  :foreign_key => :pid_entry_code,            :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :pid_age_eligibility,  :conditions => "list_name = 'AGE_ELIGIBLE_CL2'",        :foreign_key => :pid_age_eligibility_code,  :class_name => 'NcsCode', :primary_key => :local_code
  
  validates_presence_of :person
  
  delegate :age, :to => :person
  
end
