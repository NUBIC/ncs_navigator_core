# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: dwelling_household_links
#
#  created_at        :datetime
#  du_rank_code      :integer          not null
#  du_rank_other     :string(255)
#  dwelling_unit_id  :integer          not null
#  hh_du_id          :string(36)       not null
#  household_unit_id :integer          not null
#  id                :integer          not null, primary key
#  is_active_code    :integer          not null
#  psu_code          :integer          not null
#  transaction_type  :string(36)
#  updated_at        :datetime
#



# The definition of a household is really based on the individual person's definition of a family.
# The common definition is residence at the same address; however, the composition of the household might be
# parent/child; siblings; roommates, or other combinations of relationships.
#
# Household may move from one dwelling unit to another, or families that comprise a single household may split
# into two households with different addresses. If a family moves from the DU to a non-sampled address they won’t
# get a new DU-ID but we would still collect their address information as an HH. So a household can be linked to
# several dwelling units In some cases only one link is active at a time. In other cases there are Households living
# in multiple dwelling units simultaneously. Thus, there is a many to many relationship between DU and HH that must
# be defined in this table. The link that defines each DU-HH relationship contains status information about the
# relationship. The links, however, are distinguishable by other information maintained on the linking record.
#
# A new record here is created when a household is identified as associated with an address.
# It may be "updated during conversations with participants, from secondary data sources, or from other types of contacts."
#
class DwellingHouseholdLink < ActiveRecord::Base
  include NcsNavigator::Core::Mdes::MdesRecord
  acts_as_mdes_record :public_id_field => :hh_du_id

  belongs_to :dwelling_unit
  belongs_to :household_unit

  ncs_coded_attribute :psu,       'PSU_CL1'
  ncs_coded_attribute :is_active, 'CONFIRM_TYPE_CL2'
  ncs_coded_attribute :du_rank,   'COMMUNICATION_RANK_CL1'

  def self.order_by_rank(dwelling_household_links)
    dwelling_household_links.sort_by do |link|
      CommunicationRankCLOne.sort_by_index(link.du_rank)
    end
  end
end

