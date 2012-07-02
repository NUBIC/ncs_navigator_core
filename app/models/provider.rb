# -*- coding: utf-8 -*-
class Provider < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :provider_id

  ncs_coded_attribute :psu,                   'PSU_CL1'
  ncs_coded_attribute :provider_type,         'PROVIDER_TYPE_CL1'
  ncs_coded_attribute :provider_ncs_role,     'PROVIDER_STUDY_ROLE_CL1'
  ncs_coded_attribute :practice_info,         'PRACTICE_CHARACTERISTIC_CL1'
  ncs_coded_attribute :practice_patient_load, 'PRACTICE_LOAD_RANGE_CL1'
  ncs_coded_attribute :practice_size,         'PRACTICE_SIZE_RANGE_CL1'
  ncs_coded_attribute :public_practice,       'CONFIRM_TYPE_CL2'
  ncs_coded_attribute :provider_info_source,  'INFORMATION_SOURCE_CL2'
  ncs_coded_attribute :list_subsampling,      'CONFIRM_TYPE_CL2'

  has_one :address
  has_many :telephones
  has_many :person_provider_links
  has_many :patients, :class_name => "Person", :through => :person_provider_links, :source => :person
  has_many :personnel_provider_links
  has_many :staff, :class_name => "Person", :through => :personnel_provider_links, :source => :person

  has_many :contact_links, :order => "created_at DESC"
  has_many :events, :through => :contact_links
  has_many :contacts, :through => :contact_links

  has_one :pbs_list
  has_one :substitute_pbs_list, :class_name => 'PbsList', :foreign_key => 'substitute_provider_id'

  has_many :provider_logistics
  has_many :non_interview_providers

  accepts_nested_attributes_for :address, :allow_destroy => true
  accepts_nested_attributes_for :telephones, :allow_destroy => true
  accepts_nested_attributes_for :staff, :allow_destroy => true
  accepts_nested_attributes_for :provider_logistics, :allow_destroy => true

  PROVIDER_RECRUIMENT_EVENT_TYPE_CODE = 22
  ORIGINAL_IN_SAMPLE_CODE = 1
  SUBSTITUTE_IN_SAMPLE_CODE = 2

  scope :original_in_sample_providers, includes(:pbs_list).where("pbs_lists.in_sample_code = #{ORIGINAL_IN_SAMPLE_CODE}")
  scope :substitute_in_sample_providers, includes(:pbs_list).where("pbs_lists.in_sample_code = #{SUBSTITUTE_IN_SAMPLE_CODE}")

  def to_s
    self.name_practice.to_s
  end

  def primary_contact
    pc = self.personnel_provider_links.where(:primary_contact => true).first
    return pc.person unless pc.blank?
  end

  def telephone
    phone = self.telephones.where(:phone_type_code => Telephone::WORK_PHONE_CODE).first
    return phone unless phone.blank?
  end

  def fax
    phone = self.telephones.where(:phone_type_code => Telephone::FAX_PHONE_CODE).first
    return phone unless phone.blank?
  end

  def provider_recruitment_event
    self.events.where(:event_type_code => PROVIDER_RECRUIMENT_EVENT_TYPE_CODE).last
  end

  def can_recruit?
    if original_provider? || substitute_provider?
      pbs_list.recruitment_ended? ? false : true
    end
  end

  def original_provider?
    self.pbs_list.try(:in_sample_code) == 1
  end

  def substitute_provider?
    self.pbs_list.try(:in_sample_code) == 2 && self.substitute_pbs_list
  end

  def refused_to_participate?
    self.pbs_list.try(:refused_to_participate?)
  end

  def recruited?
    !self.can_recruit? && !self.refused_to_participate?
  end

end

