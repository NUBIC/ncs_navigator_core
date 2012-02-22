# == Schema Information
# Schema version: 20120222225559
#
# Table name: participant_consent_samples
#
#  id                            :integer         not null, primary key
#  psu_code                      :integer         not null
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

  ncs_coded_attribute :psu,                  'PSU_CL1'
  ncs_coded_attribute :sample_consent_type,  'CONSENT_TYPE_CL2'
  ncs_coded_attribute :sample_consent_given, 'CONFIRM_TYPE_CL2'
end
