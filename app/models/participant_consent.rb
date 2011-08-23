# Tracks the history of Participants consents and withdrawals.
class ParticipantConsent < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :participant_consent_id

  belongs_to :participant
  belongs_to :contact
  belongs_to :person_who_consented,  :class_name => "Person"
  belongs_to :person_wthdrw_consent, :class_name => "Person"
  
  belongs_to :psu,                      :conditions => "list_name = 'PSU_CL1'",                     :foreign_key => :psu_code,                      :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :consent_type,             :conditions => "list_name = 'CONSENT_TYPE_CL1'",            :foreign_key => :consent_type_code,             :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :consent_form_type,        :conditions => "list_name = 'CONSENT_TYPE_CL1'",            :foreign_key => :consent_form_type_code,        :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :consent_given,            :conditions => "list_name = 'CONFIRM_TYPE_CL2'",            :foreign_key => :consent_given_code,            :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :consent_withdraw,         :conditions => "list_name = 'CONFIRM_TYPE_CL2'",            :foreign_key => :consent_withdraw_code,         :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :consent_withdraw_type,    :conditions => "list_name = 'CONSENT_WITHDRAW_REASON_CL1'", :foreign_key => :consent_withdraw_type_code,    :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :consent_withdraw_reason,  :conditions => "list_name = 'CONSENT_WITHDRAW_REASON_CL2'", :foreign_key => :consent_withdraw_reason_code,  :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :consent_language,         :conditions => "list_name = 'LANGUAGE_CL2'",                :foreign_key => :consent_language_code,         :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :who_consented,            :conditions => "list_name = 'AGE_STATUS_CL1'",              :foreign_key => :who_consented_code,            :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :who_wthdrw_consent,       :conditions => "list_name = 'AGE_STATUS_CL3'",              :foreign_key => :who_wthdrw_consent_code,       :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :consent_translate,        :conditions => "list_name = 'TRANSLATION_METHOD_CL1'",      :foreign_key => :consent_translate_code,        :class_name => 'NcsCode', :primary_key => :local_code

  belongs_to :reconsideration_script_use, :conditions => "list_name = 'CONFIRM_TYPE_CL21'",         :foreign_key => :reconsideration_script_use_code, :class_name => 'NcsCode', :primary_key => :local_code

  validates_length_of :consent_version, :maximum => 9

end
