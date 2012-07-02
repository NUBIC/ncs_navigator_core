# -*- coding: utf-8 -*-


# Contains details about visit with the participant
# (e.g. Language spoken, Age of person that consented, etc.)
class ParticipantVisitRecord < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :rvis_id

  belongs_to :participant
  belongs_to :contact
  belongs_to :rvis_person, :class_name => "Person", :foreign_key => :rvis_person_id

  ncs_coded_attribute :psu,                  'PSU_CL1'
  ncs_coded_attribute :rvis_language,        'LANGUAGE_CL2'
  ncs_coded_attribute :rvis_who_consented,   'AGE_STATUS_CL1'
  ncs_coded_attribute :rvis_translate,       'TRANSLATION_METHOD_CL1'

  ncs_coded_attribute :rvis_sections,        'CONFIRM_TYPE_CL21'
  ncs_coded_attribute :rvis_during_interv,   'CONFIRM_TYPE_CL21'
  ncs_coded_attribute :rvis_during_bio,      'CONFIRM_TYPE_CL21'
  ncs_coded_attribute :rvis_bio_cord,        'CONFIRM_TYPE_CL21'
  ncs_coded_attribute :rvis_during_env,      'CONFIRM_TYPE_CL21'
  ncs_coded_attribute :rvis_during_thanks,   'CONFIRM_TYPE_CL21'

  ncs_coded_attribute :rvis_after_saq,       'CONFIRM_TYPE_CL21'
  ncs_coded_attribute :rvis_reconsideration, 'CONFIRM_TYPE_CL21'

end

