# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: pbs_lists
#
#  cert_flag_code                 :integer
#  created_at                     :datetime
#  frame_completion_req_code      :integer          not null
#  frame_order                    :integer
#  id                             :integer          not null, primary key
#  in_out_frame_code              :integer
#  in_out_psu_code                :integer
#  in_sample_code                 :integer
#  mos                            :integer
#  pbs_list_id                    :string(36)       not null
#  pr_cooperation_date            :date
#  pr_recruitment_end_date        :date
#  pr_recruitment_start_date      :date
#  pr_recruitment_status_code     :integer
#  practice_num                   :integer
#  provider_id                    :integer
#  psu_code                       :integer          not null
#  sampling_interval_woman        :decimal(4, 2)
#  selection_probability_location :decimal(7, 6)
#  selection_probability_overall  :decimal(7, 6)
#  selection_probability_woman    :decimal(7, 6)
#  sort_var1                      :integer
#  sort_var2                      :integer
#  sort_var3                      :integer
#  stratum                        :string(255)
#  substitute_provider_id         :integer
#  transaction_type               :string(255)
#  updated_at                     :datetime
#

class PbsList < ActiveRecord::Base
  include NcsNavigator::Core::Mdes::MdesRecord
  acts_as_mdes_record :public_id_field => :pbs_list_id

  belongs_to :provider
  belongs_to :substitute_provider, :class_name => 'Provider', :foreign_key => 'substitute_provider_id'

  validates_presence_of :provider

  ncs_coded_attribute :psu,                   'PSU_CL1'
  ncs_coded_attribute :in_out_frame,          'INOUT_FRAME_CL1'                 # MDES 3.0
  ncs_coded_attribute :in_sample,             'ORIGINAL_SUBSTITUTE_SAMPLE_CL1'  # MDES 3.0
  ncs_coded_attribute :in_out_psu,            'INOUT_PSU_CL1'                   # MDES 3.0
  ncs_coded_attribute :cert_flag,             'CERT_UNIT_CL1'                   # MDES 3.0
  ncs_coded_attribute :frame_completion_req,  'CONFIRM_TYPE_CL21'
  ncs_coded_attribute :pr_recruitment_status, 'RECRUIT_STATUS_CL1'              # MDES 3.0

  # RECRUIT_STATUS_CL1
  # 1 (Provider Recruited)
  # 2 (Provider Not Recruited)
  # 3 (Provider Recruitment In Progress)
  # 4 (Recruitment Not Started)
  # 5 (Out of scope)
  # -7 (Not Applicable)
  # -4 (Missing in Error)

  SEARCH_LOCATIONS = ["Original location", "Substitute location"]
  HOSPITAL_VALUES = [4,5]

  def self.is_hospital_type
    where(:in_out_frame_code => HOSPITAL_VALUES)
  end

  def hospital?
    HOSPITAL_VALUES.include?(in_out_frame_code)
  end

  def recruitment_started?
    !self.pr_recruitment_start_date.blank? && self.pr_recruitment_status_code == 3
  end

  def recruitment_ended?
    !self.pr_recruitment_end_date.blank? && ([1,2,5].include?(self.pr_recruitment_status_code))
  end

  ##
  # True if the pr_recruitment_end_date date is set and the recruitment status is Refused
  def refused_to_participate?
    !self.pr_recruitment_end_date.blank? && self.pr_recruitment_status_code == 2
  end

  def has_substitute_provider?
    !self.substitute_provider_id.blank?
  end

  ##
  # True if the cooperation date is set and the recruitment status is Recruited
  def provider_recruited?
    !self.pr_cooperation_date.blank? && self.pr_recruitment_status_code == 1
  end

  ##
  # Updates the pr_recruitment_start_date to the
  # earliest contact for provider recruitment
  def set_recruitment_start_date!
    self.update_attributes(:pr_recruitment_start_date => earliest_provider_recruitment_contact_date)
  end

  ##
  # Updates the pr_cooperation_date to the
  # earliest contact for provider recruitment
  # where the provider said yes to the NCS
  def set_cooperation_date!
    self.update_attributes(:pr_cooperation_date => earliest_successful_provider_recruitment_contact_date)
  end

  ##
  # Updates the pr_recruitment_end_date to the
  # latest provider logistics completion date
  def set_recruitment_end_date!
    self.update_attributes(:pr_recruitment_end_date => latest_provider_logistic_completion_date)
  end

  ##
  # Sets pr_recruitment_status to 'Provider Recruited' and
  # pr_recruitment_end_date to the earliest contact for provider recruitment
  # where the provider said yes to the NCS
  def mark_recruited!
    set_cooperation_date!
    self.update_attributes(:pr_recruitment_status_code => 1)
  end

  ##
  # Sets pr_recruitment_status to 'Provider Not Recruited'
  def mark_refused!
    self.update_attributes(:pr_recruitment_status_code => 2)
  end

  ##
  # Sets pr_recruitment_status to 'Provider Recruitment In Progress'
  def mark_in_progress!
    self.update_attributes(:pr_recruitment_status_code => 3)
  end

  ##
  # Marks recruited if logistics are completed and
  # update the provider recruitment event
  # date with latest logistic completion date
  def update_recruitment_status!
    self.mark_in_progress! if provider.has_no_provider_recruited_contacts?
    self.mark_recruited! if provider.recruitment_logistics_complete? && !provider_recruited?
    event = self.provider.try(:provider_recruitment_event)
    event.update_attributes(:event_end_date => latest_provider_logistic_completion_date) if event
  end

  def latest_provider_logistic_completion_date
    if provider.recruitment_logistics_complete?
      provider.provider_logistics.sort_by { |l| l.completion_date }.last.completion_date
    else
      nil
    end
  end

  def earliest_provider_recruitment_contact_date
    if provider_recruitment_contacts.empty?
      nil
    else
      provider_recruitment_contacts.last.contact_date_date
    end
  end

  def earliest_successful_provider_recruitment_contact_date
    provider_recruitment_contacts("AND contacts.contact_disposition = #{DispositionMapper::PROVIDER_RECRUITED}").last.try(:contact_date_date)
  end

  ##
  # Returns all contacts for this provider whose event type is
  # Provider Recruitment
  def provider_recruitment_contacts(where = "")
    provider.contacts.
      joins("inner join events on contact_links.event_id = events.id").
      where("events.event_type_code = #{Provider::PROVIDER_RECRUIMENT_EVENT_TYPE_CODE} #{where}").
      order("contact_date DESC")
  end

  ##
  # Called at create/update/delete of contact
  # or create/update/delete of logistics
  # updates the pbs_list dates appropriately
  # and opens recruitment on provider if necessary
  def update_recruitment_dates!
    set_recruitment_start_date!
    set_cooperation_date!
    set_recruitment_end_date!
    # provider.open_recruitment if provider.has_no_provider_recruited_contacts?
  end

end

