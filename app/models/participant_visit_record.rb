# == Schema Information
# Schema version: 20111018175121
#
# Table name: participant_visit_records
#
#  id                        :integer         not null, primary key
#  psu_code                  :string(36)      not null
#  rvis_id                   :binary          not null
#  participant_id            :integer
#  rvis_language_code        :integer         not null
#  rvis_language_other       :string(255)
#  rvis_person_id            :integer
#  rvis_who_consented_code   :integer         not null
#  rvis_translate_code       :integer         not null
#  contact_id                :integer
#  time_stamp_1              :datetime
#  time_stamp_2              :datetime
#  rvis_sections_code        :integer         not null
#  rvis_during_interv_code   :integer         not null
#  rvis_during_bio_code      :integer         not null
#  rvis_bio_cord_code        :integer         not null
#  rvis_during_env_code      :integer         not null
#  rvis_during_thanks_code   :integer         not null
#  rvis_after_saq_code       :integer         not null
#  rvis_reconsideration_code :integer         not null
#  transaction_type          :string(36)
#  created_at                :datetime
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
  
  belongs_to :psu,                  :conditions => "list_name = 'PSU_CL1'",                 :foreign_key => :psu_code,                  :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :rvis_language,        :conditions => "list_name = 'LANGUAGE_CL2'",            :foreign_key => :rvis_language_code,        :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :rvis_who_consented,   :conditions => "list_name = 'AGE_STATUS_CL1'",          :foreign_key => :rvis_who_consented_code,   :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :rvis_translate,       :conditions => "list_name = 'TRANSLATION_METHOD_CL1'",  :foreign_key => :rvis_translate_code,       :class_name => 'NcsCode', :primary_key => :local_code
  
  belongs_to :rvis_sections,        :conditions => "list_name = 'CONFIRM_TYPE_CL21'",       :foreign_key => :rvis_sections_code,        :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :rvis_during_interv,   :conditions => "list_name = 'CONFIRM_TYPE_CL21'",       :foreign_key => :rvis_during_interv_code,   :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :rvis_during_bio,      :conditions => "list_name = 'CONFIRM_TYPE_CL21'",       :foreign_key => :rvis_during_bio_code,      :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :rvis_bio_cord,        :conditions => "list_name = 'CONFIRM_TYPE_CL21'",       :foreign_key => :rvis_bio_cord_code,        :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :rvis_during_env,      :conditions => "list_name = 'CONFIRM_TYPE_CL21'",       :foreign_key => :rvis_during_env_code,      :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :rvis_during_thanks,   :conditions => "list_name = 'CONFIRM_TYPE_CL21'",       :foreign_key => :rvis_during_thanks_code,   :class_name => 'NcsCode', :primary_key => :local_code

  belongs_to :rvis_after_saq,       :conditions => "list_name = 'CONFIRM_TYPE_CL21'",       :foreign_key => :rvis_after_saq_code,       :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :rvis_reconsideration, :conditions => "list_name = 'CONFIRM_TYPE_CL21'",       :foreign_key => :rvis_reconsideration_code, :class_name => 'NcsCode', :primary_key => :local_code

end
