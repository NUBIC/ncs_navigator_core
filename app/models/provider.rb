# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: providers
#
#  created_at                 :datetime
#  id                         :integer          not null, primary key
#  institution_id             :integer
#  list_subsampling_code      :integer
#  name_practice              :string(100)
#  practice_info_code         :integer          not null
#  practice_patient_load_code :integer          not null
#  practice_size_code         :integer          not null
#  proportion_days_sampled    :integer
#  proportion_weeks_sampled   :integer
#  provider_comment           :text
#  provider_id                :string(36)       not null
#  provider_info_date         :date
#  provider_info_source_code  :integer          not null
#  provider_info_source_other :string(255)
#  provider_info_update       :date
#  provider_ncs_role_code     :integer          not null
#  provider_ncs_role_other    :string(255)
#  provider_type_code         :integer          not null
#  provider_type_other        :string(255)
#  psu_code                   :integer          not null
#  public_practice_code       :integer          not null
#  sampling_notes             :string(1000)
#  transaction_type           :string(255)
#  updated_at                 :datetime
#

class Provider < ActiveRecord::Base
  include NcsNavigator::Core::Mdes::MdesRecord
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
  has_many :pre_screening_performeds

  has_many :provider_roles
  has_many :pbs_provider_roles, :class_name => 'PbsProviderRole', :foreign_key => 'provider_id'

  has_many :person_provider_links
  has_many :people, :through => :person_provider_links
  has_many :sampled_persons_ineligibilities

  belongs_to :institution

  accepts_nested_attributes_for :address, :allow_destroy => true
  accepts_nested_attributes_for :telephones, :allow_destroy => true
  accepts_nested_attributes_for :staff, :allow_destroy => true
  accepts_nested_attributes_for :provider_logistics, :allow_destroy => true
  accepts_nested_attributes_for :provider_roles, :allow_destroy => true
  accepts_nested_attributes_for :pbs_provider_roles, :allow_destroy => true
  accepts_nested_attributes_for :pre_screening_performeds, :allow_destroy => true

  validates :name_practice, :length => { :maximum => 100 }, :allow_blank => true

  PROVIDER_RECRUIMENT_EVENT_TYPE_CODE = 22
  ORIGINAL_IN_SAMPLE_CODE = 1
  SUBSTITUTE_IN_SAMPLE_CODE = 2

  scope :original_in_sample_providers, includes(:pbs_list).where("pbs_lists.in_sample_code = #{ORIGINAL_IN_SAMPLE_CODE}")
  scope :substitute_in_sample_providers, includes(:pbs_list).where("pbs_lists.in_sample_code = #{SUBSTITUTE_IN_SAMPLE_CODE}")

  after_save :open_recruitment

  def self.last_modified
    maximum(:updated_at)
  end

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

  def original_provider?
    self.pbs_list.try(:in_sample_code) == 1
  end

  def substitute_provider?
    self.pbs_list.try(:in_sample_code) == 2 &&
      self.substitute_pbs_list
  end

  def refused_to_participate?
    self.pbs_list.try(:refused_to_participate?)
  end

  def recruited?
    self.pbs_list.try(:provider_recruited?) && !self.refused_to_participate?
  end

  ##
  # True if provider logistics and all are marked complete
  def recruitment_logistics_complete?
    if provider_logistics.empty?
      false
    else
      provider_logistics.select { |l| l.complete? }.count ==
        provider_logistics.size
    end
  end

  ##
  # Set the pbs list pr_recruitment_end_date attribute to nil
  # if any of the provider logistics are not complete or
  # there are no provider recruited contacts
  def open_recruitment
    if self.pbs_list && has_no_provider_recruited_contacts?
      self.pbs_list.update_attribute(:pr_recruitment_status_code, 3)
    end
  end

  ##
  # True if no contact disposition is Provider Recruited
  def has_no_provider_recruited_contacts?
    self.contacts.find{ |c| c.contact_disposition == DispositionMapper::PROVIDER_RECRUITED }.blank?
  end

end

