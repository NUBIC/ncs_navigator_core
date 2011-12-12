# == Schema Information
# Schema version: 20111205213437
#
# Table name: household_person_links
#
#  id                :integer         not null, primary key
#  psu_code          :string(36)      not null
#  person_hh_id      :string(36)      not null
#  person_id         :integer         not null
#  household_unit_id :integer         not null
#  is_active_code    :integer         not null
#  hh_rank_code      :integer         not null
#  hh_rank_other     :string(255)
#  transaction_type  :string(36)
#  created_at        :datetime
#  updated_at        :datetime
#

# Sometimes a person may split from a household and either enter a household
# that has already been identified or, alternatively, create a new household.
# A person who moves from one household to another will have multiple Person
# Household linking records. In some cases only one link is active at a time.
# In other cases there are Persons who live in multiple households simultaneously.
# Someone in school might live both on campus and “at home,” or an NCS child may
# live with both a mother and father who reside at different addresses. In this event
# both links would be active. The links, however, are distinguishable by other
# information maintained on the linking record.
class HouseholdPersonLink < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :person_hh_id

  belongs_to :person
  belongs_to :household_unit

  belongs_to :psu,       :conditions => "list_name = 'PSU_CL1'",                :foreign_key => :psu_code,        :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :is_active, :conditions => "list_name = 'CONFIRM_TYPE_CL2'",       :foreign_key => :is_active_code,  :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :hh_rank,   :conditions => "list_name = 'COMMUNICATION_RANK_CL1'", :foreign_key => :hh_rank_code,    :class_name => 'NcsCode', :primary_key => :local_code
end
