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
