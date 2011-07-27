# == Schema Information
# Schema version: 20110726214159
#
# Table name: addresses
#
#  id                        :integer         not null, primary key
#  psu_code                  :integer         not null
#  address_id                :binary          not null
#  person_id                 :integer
#  dwelling_unit_id          :integer         not null
#  address_rank_code         :integer         not null
#  address_rank_other        :string(255)
#  address_info_source_code  :integer         not null
#  address_info_source_other :string(255)
#  address_info_mode_code    :integer         not null
#  address_info_mode_other   :string(255)
#  address_info_date         :date
#  address_info_update       :date
#  address_start_date        :string(10)
#  address_start_date_date   :date
#  address_end_date          :string(10)
#  address_end_date_date     :date
#  address_type_code         :integer         not null
#  address_type_other        :string(255)
#  address_description_code  :integer         not null
#  address_description_other :string(255)
#  address_one               :string(100)
#  address_two               :string(100)
#  unit                      :string(10)
#  city                      :string(50)
#  state_code                :integer         not null
#  zip                       :string(5)
#  zip4                      :string(4)
#  address_comment           :text
#  transaction_type          :string(255)
#  created_at                :datetime
#  updated_at                :datetime
#

class Address < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :address_id, :date_fields => [:address_start_date, :address_end_date]
  
  belongs_to :person
  belongs_to :dwelling_unit
  belongs_to :psu,                  :conditions => "list_name = 'PSU_CL1'",                 :foreign_key => :psu_code,                  :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :address_rank,         :conditions => "list_name = 'COMMUNICATION_RANK_CL1'",  :foreign_key => :address_rank_code,         :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :address_info_source,  :conditions => "list_name = 'INFORMATION_SOURCE_CL1'",  :foreign_key => :address_info_source_code,  :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :address_info_mode,    :conditions => "list_name = 'CONTACT_TYPE_CL1'",        :foreign_key => :address_info_mode_code,    :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :address_type,         :conditions => "list_name = 'ADDRESS_CATEGORY_CL1'",    :foreign_key => :address_type_code,         :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :address_description,  :conditions => "list_name = 'RESIDENCE_TYPE_CL1'",      :foreign_key => :address_description_code,  :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :state,                :conditions => "list_name = 'STATE_CL1'",               :foreign_key => :state_code,                :class_name => 'NcsCode', :primary_key => :local_code
  
  def to_s
    addr = []
    addr << address_one
    addr << address_two
    addr << unit
    addr << city
    addr << state.to_s unless state.local_code == -4
    if zip4.blank?
      addr << zip
    else
      addr << "#{zip}-#{zip4}" unless zip.blank?
    end
    addr.reject { |n| n.blank? }.join(' ')
  end
  
end
