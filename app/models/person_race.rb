# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: person_races
#
#  created_at       :datetime
#  id               :integer          not null, primary key
#  person_id        :integer          not null
#  person_race_id   :string(36)       not null
#  psu_code         :integer          not null
#  race_code        :integer          not null
#  race_other       :string(255)
#  transaction_type :string(36)
#  updated_at       :datetime
#



# A Person may be of mixed race. This table records each race for a Person in a separate row.
class PersonRace < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :person_race_id

  belongs_to :person
  ncs_coded_attribute :psu,  'PSU_CL1'
  ncs_coded_attribute :race, 'RACE_CL1'

  # Validating :person_id instead of :person prevents a reload of the
  # associated object when creating an instance alone. This provides a
  # huge speedup in the importer; if validating the associated
  # instance is necessary, we should provide a scoped validation so it
  # can be excluded in the importer context.
  validates_presence_of :person_id
end

