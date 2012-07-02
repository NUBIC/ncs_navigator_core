

# A Person, an Institution and a Provider will have at least one and sometimes many phone numbers.
class Telephone < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :phone_id, :date_fields => [:phone_start_date, :phone_end_date]

  belongs_to :person
  # belongs_to :institute
  belongs_to :provider
  belongs_to :response_set

  ncs_coded_attribute :psu,               'PSU_CL1'
  ncs_coded_attribute :phone_info_source, 'INFORMATION_SOURCE_CL2'
  ncs_coded_attribute :phone_type,        'PHONE_TYPE_CL1'
  ncs_coded_attribute :phone_rank,        'COMMUNICATION_RANK_CL1'
  ncs_coded_attribute :phone_landline,    'CONFIRM_TYPE_CL2'
  ncs_coded_attribute :phone_share,       'CONFIRM_TYPE_CL2'
  ncs_coded_attribute :cell_permission,   'CONFIRM_TYPE_CL2'
  ncs_coded_attribute :text_permission,   'CONFIRM_TYPE_CL2'

  HOME_PHONE_CODE = 1
  WORK_PHONE_CODE = 2
  CELL_PHONE_CODE = 3
  FAX_PHONE_CODE  = 4

  def to_s
    self.phone_nbr
  end

  def self.home_phone_type
    NcsCode.where(:list_name => "PHONE_TYPE_CL1").where(:local_code => HOME_PHONE_CODE).first
  end

  def self.work_phone_type
    NcsCode.where(:list_name => "PHONE_TYPE_CL1").where(:local_code => WORK_PHONE_CODE).first
  end

  def self.cell_phone_type
    NcsCode.where(:list_name => "PHONE_TYPE_CL1").where(:local_code => CELL_PHONE_CODE).first
  end

  def self.fax_phone_type
    NcsCode.where(:list_name => "PHONE_TYPE_CL1").where(:local_code => FAX_PHONE_CODE).first
  end

  def self.other_phone_type
    NcsCode.where(:list_name => "PHONE_TYPE_CL1").where(:local_code => -5).first
  end

  def phone_nbr=(nbr)
    self[:phone_nbr] = nbr.scan(/\d/).join if nbr.is_a? String
  end

  ##
  # Updates the rank to secondary if current rank is primary
  def demote_primary_rank_to_secondary
    return unless self.phone_rank_code == 1
    secondary_rank = NcsCode.for_list_name_and_local_code('COMMUNICATION_RANK_CL1', 2)
    if !secondary_rank.blank?
      self.phone_rank = secondary_rank
      self.save
    end
  end

end

