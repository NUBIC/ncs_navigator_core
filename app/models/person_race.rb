# == Schema Information
# Schema version: 20111212224350
#
# Table name: person_races
#
#  id               :integer         not null, primary key
#  psu_code         :integer         not null
#  person_race_id   :string(36)      not null
#  person_id        :integer         not null
#  race_code        :integer         not null
#  race_other       :string(255)
#  transaction_type :string(36)
#  created_at       :datetime
#  updated_at       :datetime
#

# A Person may be of mixed race. This table records each race for a Person in a separate row.
class PersonRace < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :person_race_id

  belongs_to :person
  ncs_coded_attribute :psu,  'PSU_CL1'
  ncs_coded_attribute :race, 'RACE_CL1'

  validates_presence_of :person
end
