# == Schema Information
# Schema version: 20120120165946
#
# Table name: participant_consents
#
#  id                              :integer         not null, primary key
#  psu_code                        :integer         not null
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

  ncs_coded_attribute :psu,                        'PSU_CL1'
  ncs_coded_attribute :consent_type,               'CONSENT_TYPE_CL1'
  ncs_coded_attribute :consent_form_type,          'CONSENT_TYPE_CL1'
  ncs_coded_attribute :consent_given,              'CONFIRM_TYPE_CL2'
  ncs_coded_attribute :consent_withdraw,           'CONFIRM_TYPE_CL2'
  ncs_coded_attribute :consent_withdraw_type,      'CONSENT_WITHDRAW_REASON_CL1'
  ncs_coded_attribute :consent_withdraw_reason,    'CONSENT_WITHDRAW_REASON_CL2'
  ncs_coded_attribute :consent_language,           'LANGUAGE_CL2'
  ncs_coded_attribute :who_consented,              'AGE_STATUS_CL1'
  ncs_coded_attribute :who_wthdrw_consent,         'AGE_STATUS_CL3'
  ncs_coded_attribute :consent_translate,          'TRANSLATION_METHOD_CL1'

  ncs_coded_attribute :reconsideration_script_use, 'CONFIRM_TYPE_CL21'

  validates_length_of :consent_version, :maximum => 9
  
  def self.consent_types
    NcsNavigatorCore.mdes.types.find { |t| t.name == 'consent_type_cl1' }.
      code_list.collect { |cl| [cl.value, cl.label.to_s.strip] }
  end
  
  def self.low_intensity_consent_types
    consent_types.select { |c| c[0] == "7" } # low intensity consent code
  end
  
  def self.high_intensity_consent_types
    consent_types.select { |c| c[0] != "7" && c[0] != "-4" } # high intensity consent codes
  end

end
