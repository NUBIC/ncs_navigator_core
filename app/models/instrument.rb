# == Schema Information
# Schema version: 20111110015749
#
# Table name: instruments
#
#  id                       :integer         not null, primary key
#  psu_code                 :integer         not null
#  instrument_id            :string(36)      not null
#  event_id                 :integer
#  instrument_type_code     :integer         not null
#  instrument_type_other    :string(255)
#  instrument_version       :string(36)      not null
#  instrument_repeat_key    :integer
#  instrument_start_date    :date
#  instrument_start_time    :string(255)
#  instrument_end_date      :date
#  instrument_end_time      :string(255)
#  instrument_breakoff_code :integer         not null
#  instrument_status_code   :integer         not null
#  instrument_mode_code     :integer         not null
#  instrument_mode_other    :string(255)
#  instrument_method_code   :integer         not null
#  supervisor_review_code   :integer         not null
#  data_problem_code        :integer         not null
#  instrument_comment       :text
#  transaction_type         :string(255)
#  created_at               :datetime
#  updated_at               :datetime
#  person_id                :integer
#  survey_id                :integer
#

# An Instrument is a scheduled, partially executed or 
# completely executed questionnaire or paper form. An 
# Instrument can also be an Electronic Health Record or 
# a Personal Health Record.
class Instrument < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :instrument_id
  
  belongs_to :event
  belongs_to :psu,                  :conditions => "list_name = 'PSU_CL1'",                     :foreign_key => :psu_code,                  :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :instrument_type,      :conditions => "list_name = 'INSTRUMENT_TYPE_CL1'",         :foreign_key => :instrument_type_code,      :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :instrument_breakoff,  :conditions => "list_name = 'CONFIRM_TYPE_CL2'",            :foreign_key => :instrument_breakoff_code,  :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :instrument_status,    :conditions => "list_name = 'INSTRUMENT_STATUS_CL1'",       :foreign_key => :instrument_status_code,    :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :instrument_mode,      :conditions => "list_name = 'INSTRUMENT_ADMIN_MODE_CL1'",   :foreign_key => :instrument_mode_code,      :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :instrument_method,    :conditions => "list_name = 'INSTRUMENT_ADMIN_METHOD_CL1'", :foreign_key => :instrument_method_code,    :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :supervisor_review,    :conditions => "list_name = 'CONFIRM_TYPE_CL2'",            :foreign_key => :supervisor_review_code,    :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :data_problem,         :conditions => "list_name = 'CONFIRM_TYPE_CL2'",            :foreign_key => :data_problem_code,         :class_name => 'NcsCode', :primary_key => :local_code  
  
  belongs_to :person
  belongs_to :survey
  
  validates_presence_of :instrument_version
  
  ##
  # Display text from the NcsCode list INSTRUMENT_TYPE_CL1 
  # cf. instrument_type belongs_to association
  # @return [String]
  def to_s
    instrument_type.to_s
  end
  
  def complete?
    !instrument_end_date.blank? && !instrument_end_time.blank?
  end
  
end
