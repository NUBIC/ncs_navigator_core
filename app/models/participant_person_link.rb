# == Schema Information
# Schema version: 20111205213437
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
  ncs_coded_attribute :psu,          'PSU_CL1'
  ncs_coded_attribute :relationship, 'PERSON_PARTCPNT_RELTNSHP_CL1'
  ncs_coded_attribute :is_active,    'CONFIRM_TYPE_CL2'

  validates_presence_of :person
  validates_presence_of :participant

  def initialize(*args)
    super
    if self.is_active_code.blank?
      self.is_active_code = 1
    end
  end

  def active?
    is_active_code == 1
  end
end
