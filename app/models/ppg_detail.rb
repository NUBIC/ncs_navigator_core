# Basic non-repeating Pregnancy Probability Group (PPG) status information 
# is stored here for each woman who completes a pregnancy screener. 
# Eligibility criteria for administration of the pregnancy screener are based on 4 elements: 
# * gender (i.e., female); 
# * primary residence (i.e., participant lives in a sampled Dwelling Unit); 
# * age (i.e., 18-49); 
# * currently known as pregnant – regardless of age. 
# 
# In the event that a mother has several pregnancies, each pregnancy would have its own 
# PPG Details record. 
# There is a one-to-many relationship between Participant and PPG Details.
class PpgDetail < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :ppg_details_id

  belongs_to :participant
  belongs_to :psu,            :conditions => "list_name = 'PSU_CL1'",                 :foreign_key => :psu_code,              :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :ppg_pid_status, :conditions => "list_name = 'PARTICIPANT_STATUS_CL1'",  :foreign_key => :ppg_pid_status_code,   :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :ppg_first,      :conditions => "list_name = 'PPG_STATUS_CL2'",          :foreign_key => :ppg_first_code,        :class_name => 'NcsCode', :primary_key => :local_code

end
