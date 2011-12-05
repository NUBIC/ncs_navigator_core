# == Schema Information
# Schema version: 20111205175632
#
# Table name: participant_consent_samples
#
#  id                            :integer         not null, primary key
#  psu_code                      :string(36)      not null
#  participant_consent_sample_id :string(36)      not null
#  participant_id                :integer
#  participant_consent_id        :integer
#  sample_consent_type_code      :integer         not null
#  sample_consent_given_code     :integer         not null
#  transaction_type              :string(36)
#  created_at                    :datetime
#  updated_at                    :datetime
#

# Table for types of samples (e.g. Biospecimen, Genetic, etc.) that require Participant consent for collection.
class ParticipantConsentSample < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :participant_consent_sample_id

  belongs_to :participant
  belongs_to :participant_consent
  
  belongs_to :psu,                   :conditions => "list_name = 'PSU_CL1'",           :foreign_key => :psu_code,                  :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :sample_consent_type,   :conditions => "list_name = 'CONSENT_TYPE_CL2'",  :foreign_key => :sample_consent_type_code,  :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :sample_consent_given,  :conditions => "list_name = 'CONFIRM_TYPE_CL2'",  :foreign_key => :sample_consent_given_code, :class_name => 'NcsCode', :primary_key => :local_code
end
