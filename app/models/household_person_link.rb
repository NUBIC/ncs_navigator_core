# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: household_person_links
#
#  created_at        :datetime
#  hh_rank_code      :integer          not null
#  hh_rank_other     :string(255)
#  household_unit_id :integer          not null
#  id                :integer          not null, primary key
#  is_active_code    :integer          not null
#  person_hh_id      :string(36)       not null
#  person_id         :integer          not null
#  psu_code          :integer          not null
#  transaction_type  :string(36)
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
  include NcsNavigator::Core::Mdes::MdesRecord
  acts_as_mdes_record :public_id_field => :person_hh_id

  belongs_to :person
  belongs_to :household_unit

  ncs_coded_attribute :psu,       'PSU_CL1'
  ncs_coded_attribute :is_active, 'CONFIRM_TYPE_CL2'
  ncs_coded_attribute :hh_rank,   'COMMUNICATION_RANK_CL1'

  def self.order_by_rank(household_person_links)
    household_person_links.sort_by do |link|
      CommunicationRankCLOne.sort_by_index(link.hh_rank)
    end
  end
end

