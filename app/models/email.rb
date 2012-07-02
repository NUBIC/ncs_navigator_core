

# A Person, an Institution and a Provider will have at least one and sometimes many Email addresses.
class Email < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :email_id, :date_fields => [:email_start_date, :email_end_date]

  belongs_to :person
  belongs_to :response_set

  ncs_coded_attribute :psu,               'PSU_CL1'
  ncs_coded_attribute :email_info_source, 'INFORMATION_SOURCE_CL2'
  ncs_coded_attribute :email_type,        'EMAIL_TYPE_CL1'
  ncs_coded_attribute :email_rank,        'COMMUNICATION_RANK_CL1'
  ncs_coded_attribute :email_share,       'CONFIRM_TYPE_CL2'
  ncs_coded_attribute :email_active,      'CONFIRM_TYPE_CL2'

  def to_s
    self.email
  end

  ##
  # Updates the rank to secondary if current rank is primary
  def demote_primary_rank_to_secondary
    return unless self.email_rank_code == 1
    secondary_rank = NcsCode.for_list_name_and_local_code('COMMUNICATION_RANK_CL1', 2)
    if !secondary_rank.blank?
      self.email_rank = secondary_rank
      self.save
    end
  end

end

