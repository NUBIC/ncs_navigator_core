# == Schema Information
# Schema version: 20111110015749
#
# Table name: participant_person_links
#
#  id                 :integer         not null, primary key
#  psu_code           :string(36)      not null
#  person_id          :integer         not null
#  participant_id     :integer         not null
#  relationship_code  :integer         not null
#  relationship_other :string(255)
#  is_active_code     :integer         not null
#  transaction_type   :string(36)
#  person_pid_id      :string(36)      not null
#  created_at         :datetime
#  updated_at         :datetime
#

# The same Person can be a respondent or informant for many Participants. 
# One Participant can have many respondents or informants who provide 
# information about him/her. As a consequence, there is a many to many 
# relationship between Participant and Person. The link that defines this 
# relationship contains specific information about the relationship.
class ParticipantPersonLink < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :person_pid_id
  
  belongs_to :person
  belongs_to :participant
  belongs_to :psu,          :conditions => "list_name = 'PSU_CL1'",                       :foreign_key => :psu_code,          :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :relationship, :conditions => "list_name = 'PERSON_PARTCPNT_RELTNSHP_CL1'",  :foreign_key => :relationship_code, :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :is_active,    :conditions => "list_name = 'CONFIRM_TYPE_CL2'",              :foreign_key => :is_active_code,    :class_name => 'NcsCode', :primary_key => :local_code
  
  validates_presence_of :person
  validates_presence_of :participant
end
