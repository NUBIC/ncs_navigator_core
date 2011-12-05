# == Schema Information
# Schema version: 20111205175632
#
# Table name: participant_consents
#
#  id                              :integer         not null, primary key
#  psu_code                        :string(36)      not null
#  participant_consent_id          :string(36)      not null
#  participant_id                  :integer
#  consent_version                 :string(9)
#  consent_expiration              :date
#  consent_type_code               :integer         not null
#  consent_form_type_code          :integer         not null
#  consent_given_code              :integer         not null
#  consent_date                    :date
#  consent_withdraw_code           :integer         not null
#  consent_withdraw_type_code      :integer         not null
#  consent_withdraw_reason_code    :integer         not null
#  consent_withdraw_date           :date
#  consent_language_code           :integer         not null
#  consent_language_other          :string(255)
#  person_who_consented_id         :integer
#  who_consented_code              :integer         not null
#  person_wthdrw_consent_id        :integer
#  who_wthdrw_consent_code         :integer         not null
#  consent_translate_code          :integer         not null
#  consent_comments                :text
#  contact_id                      :integer
#  reconsideration_script_use_code :integer         not null
#  transaction_type                :string(36)
#  created_at                      :datetime
#  updated_at                      :datetime
#

# Tracks the history of Participants consents and withdrawals.
class ParticipantConsent < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :participant_consent_id

  belongs_to :participant
  belongs_to :contact
  belongs_to :person_who_consented,  :class_name => "Person", :foreign_key => :person_who_consented_id
  belongs_to :person_wthdrw_consent, :class_name => "Person", :foreign_key => :person_wthdrw_consent_id
  
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
