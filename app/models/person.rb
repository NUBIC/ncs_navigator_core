# == Schema Information
# Schema version: 20110624163825
#
# Table name: people
#
#  id                             :integer         not null, primary key
#  psu_code                       :string(36)      not null
#  prefix_code                    :integer         not null
#  first_name                     :string(30)
#  last_name                      :string(30)
#  middle_name                    :string(30)
#  maiden_name                    :string(30)
#  suffix_code                    :integer         not null
#  title                          :string(5)
#  sex_code                       :integer
#  age                            :integer
#  age_range_code                 :integer         not null
#  person_dob                     :string(10)
#  date_of_birth                  :date
#  deceased_code                  :integer         not null
#  ethnic_group_code              :integer         not null
#  language_code                  :integer         not null
#  language_other                 :string(255)
#  marital_status_code            :integer         not null
#  marital_status_other           :string(255)
#  preferred_contact_method_code  :integer         not null
#  preferred_contact_method_other :string(255)
#  planned_move_code              :integer         not null
#  move_info_code                 :integer         not null
#  when_move_code                 :integer         not null
#  moving_date                    :date
#  date_move                      :string(255)
#  p_tracing_code                 :integer         not null
#  p_info_source_code             :integer         not null
#  p_info_source_other            :string(255)
#  p_info_date                    :date
#  p_info_update                  :date
#  person_comment                 :text
#  transaction_type               :string(36)
#  created_at                     :datetime
#  updated_at                     :datetime
#

class Person < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :person_id
  
  belongs_to :psu,                      :conditions => "list_name = 'PSU_CL1'",                 :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :psu_code
  belongs_to :prefix,                   :conditions => "list_name = 'NAME_PREFIX_CL1'",         :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :prefix_code
  belongs_to :suffix,                   :conditions => "list_name = 'NAME_SUFFIX_CL1'",         :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :suffix_code
  belongs_to :sex,                      :conditions => "list_name = 'GENDER_CL1'",              :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :sex_code
  belongs_to :age_range,                :conditions => "list_name = 'AGE_RANGE_CL1'",           :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :age_range_code
  belongs_to :deceased,                 :conditions => "list_name = 'CONFIRM_TYPE_CL2'",        :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :deceased_code
  belongs_to :ethnic_group,             :conditions => "list_name = 'ETHNICITY_CL1'",           :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :ethnic_group_code
  belongs_to :language,                 :conditions => "list_name = 'LANGUAGE_CL2'",            :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :language_code
  belongs_to :marital_status,           :conditions => "list_name = 'MARITAL_STATUS_CL1'",      :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :marital_status_code
  belongs_to :preferred_contact_method, :conditions => "list_name = 'CONTACT_TYPE_CL1'",        :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :preferred_contact_method_code
  belongs_to :planned_move,             :conditions => "list_name = 'CONFIRM_TYPE_CL1'",        :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :planned_move_code
  belongs_to :move_info,                :conditions => "list_name = 'MOVING_PLAN_CL1'",         :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :move_info_code
  belongs_to :when_move,                :conditions => "list_name = 'CONFIRM_TYPE_CL4'",        :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :when_move_code
  belongs_to :p_tracing,                :conditions => "list_name = 'CONFIRM_TYPE_CL2'",        :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :p_tracing_code
  belongs_to :p_info_source,            :conditions => "list_name = 'INFORMATION_SOURCE_CL4'",  :class_name => 'NcsCode', :primary_key => :local_code, :foreign_key => :p_info_source_code
  
  validates_presence_of :first_name
  validates_presence_of :last_name
  
end
