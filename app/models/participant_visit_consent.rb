# == Schema Information
# Schema version: 20111205175632
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
  
  belongs_to :psu,                  :conditions => "list_name = 'PSU_CL1'",                 :foreign_key => :psu_code,                  :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :vis_consent_type,     :conditions => "list_name = 'VISIT_TYPE_CL1'",          :foreign_key => :vis_consent_type_code,     :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :vis_consent_response, :conditions => "list_name = 'CONFIRM_TYPE_CL2'",        :foreign_key => :vis_consent_response_code, :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :vis_language,         :conditions => "list_name = 'LANGUAGE_CL2'",            :foreign_key => :vis_language_code,         :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :vis_who_consented,    :conditions => "list_name = 'AGE_STATUS_CL1'",          :foreign_key => :vis_who_consented_code,    :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :vis_translate,        :conditions => "list_name = 'TRANSLATION_METHOD_CL1'",  :foreign_key => :vis_translate_code,        :class_name => 'NcsCode', :primary_key => :local_code
  
end
