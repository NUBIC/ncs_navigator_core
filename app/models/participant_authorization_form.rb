

# Table for types of forms used to obtain authorizations from the Participant.
class ParticipantAuthorizationForm < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :auth_form_id

  belongs_to :participant
  belongs_to :contact
  # belongs_to :provider

  ncs_coded_attribute :psu,            'PSU_CL1'
  ncs_coded_attribute :auth_form_type, 'AUTH_FORM_TYPE_CL1'
  ncs_coded_attribute :auth_status,    'AUTH_STATUS_CL1'

end

