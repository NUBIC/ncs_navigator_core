# == Schema Information
# Schema version: 20110715213911
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
#  person_pid_id      :binary          not null
#  created_at         :datetime
#  updated_at         :datetime
#

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
