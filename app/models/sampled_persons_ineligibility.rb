# == Schema Information
# Schema version: 20130325201322
#
# Table name: sampled_persons_ineligibilities
#
#  age_eligible_code         :integer
#  county_of_residence_code  :integer
#  created_at                :datetime
#  first_prenatal_visit_code :integer
#  id                        :integer          not null, primary key
#  ineligible_by_code        :integer
#  person_id                 :integer
#  pregnancy_eligible_code   :integer
#  provider_id               :integer
#  psu_code                  :integer          not null
#  sampled_persons_inelig_id :string(36)       not null
#  transaction_type          :string(36)
#  updated_at                :datetime
#

class SampledPersonsIneligibility < ActiveRecord::Base

	include NcsNavigator::Core::Mdes::MdesRecord

  acts_as_mdes_record :public_id_field => :sampled_persons_inelig_id

  ncs_coded_attribute :psu,                     'PSU_CL1'
  ncs_coded_attribute :age_eligible,            'CONFIRM_TYPE_CL3'
  ncs_coded_attribute :county_of_residence,     'CONFIRM_TYPE_CL3'
  ncs_coded_attribute :first_prenatal_visit,    'CONFIRM_TYPE_CL3'
  ncs_coded_attribute :pregnancy_eligible,      'CONFIRM_TYPE_CL3'
  ncs_coded_attribute :ineligible_by,           'INELIG_SOURCE_CL1'

  belongs_to :provider
  belongs_to :person

  def self.create_from_person!(person)
    participant = person.participant
    code = lambda { |value| value ? NcsCode::YES : NcsCode::NO }
    if participant.birth_cohort?
      create!({
        :person => person,
        :provider => person.provider,
        :psu_code => person.psu_code,
        :age_eligible_code => code[participant.age_eligible?(person)],
        :county_of_residence_code => code[participant.psu_county_eligible?(person)],
        :first_prenatal_visit_code => NcsCode::UNKNOWN,
        :pregnancy_eligible_code => NcsCode::UNKNOWN
      })
    else
      create!({
        :person => person,
        :provider => person.provider,
        :psu_code => person.psu_code,
        :age_eligible_code => code[participant.age_eligible?(person)],
        :county_of_residence_code => code[participant.psu_county_eligible?(person)],
        :first_prenatal_visit_code => code[participant.first_visit?(person)],
        :pregnancy_eligible_code => code[participant.pbs_pregnant?(person)]
      })
    end
  end

end
