# == Schema Information
# Schema version: 20111205213437
#
# Table name: participant_visit_consents
#
#  id                          :integer         not null, primary key
#  psu_code                    :string(36)      not null
#  pid_visit_consent_id        :string(36)      not null
#  participant_id              :integer
#  vis_consent_type_code       :integer         not null
#  vis_consent_response_code   :integer         not null
#  vis_language_code           :integer         not null
#  vis_language_other          :string(255)
#  vis_person_who_consented_id :integer
#  vis_who_consented_code      :integer         not null
#  vis_translate_code          :integer         not null
#  vis_comments                :text
#  contact_id                  :integer
#  transaction_type            :string(36)
#  created_at                  :datetime
#  updated_at                  :datetime
#

# In addition to the single time consents we have participants review and give oral consent to specific
# data collection components that occur at a specific visit. These are presented on what is called the
# Visit Information Sheet or VIS. The VIS is specific to a specific Event and needs to be linked back to
# that. Also, multiple activities (instruments/specimens, etc) are represented on a VIS so we need to
# isolate out consent or dissent for each activity. Each row of the Participant Visit Consent table is
# a unique consent given at a specific component at a specific visit
class ParticipantVisitConsent < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :pid_visit_consent_id

  belongs_to :participant
  belongs_to :contact
  belongs_to :vis_person_who_consented,  :class_name => "Person", :foreign_key => :vis_person_who_consented_id

  ncs_coded_attribute :psu,                  'PSU_CL1'
  ncs_coded_attribute :vis_consent_type,     'VISIT_TYPE_CL1'
  ncs_coded_attribute :vis_consent_response, 'CONFIRM_TYPE_CL2'
  ncs_coded_attribute :vis_language,         'LANGUAGE_CL2'
  ncs_coded_attribute :vis_who_consented,    'AGE_STATUS_CL1'
  ncs_coded_attribute :vis_translate,        'TRANSLATION_METHOD_CL1'

end
