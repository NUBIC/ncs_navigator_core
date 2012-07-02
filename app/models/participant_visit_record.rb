# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: participant_visit_records
#
#  contact_id                :integer
#  created_at                :datetime
#  id                        :integer          not null, primary key
#  participant_id            :integer
#  psu_code                  :integer          not null
#  rvis_after_saq_code       :integer          not null
#  rvis_bio_cord_code        :integer          not null
#  rvis_during_bio_code      :integer          not null
#  rvis_during_env_code      :integer          not null
#  rvis_during_interv_code   :integer          not null
#  rvis_during_thanks_code   :integer          not null
#  rvis_id                   :string(36)       not null
#  rvis_language_code        :integer          not null
#  rvis_language_other       :string(255)
#  rvis_person_id            :integer
#  rvis_reconsideration_code :integer          not null
#  rvis_sections_code        :integer          not null
#  rvis_translate_code       :integer          not null
#  rvis_who_consented_code   :integer          not null
#  time_stamp_1              :datetime
#  time_stamp_2              :datetime
#  transaction_type          :string(36)
#  updated_at                :datetime
#



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

