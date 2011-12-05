# == Schema Information
# Schema version: 20111205175632
#
# Table name: participant_authorization_forms
#
#  id                  :integer         not null, primary key
#  psu_code            :string(36)      not null
#  auth_form_id        :string(36)      not null
#  participant_id      :integer
#  contact_id          :integer
#  provider_id         :integer
#  auth_form_type_code :integer         not null
#  auth_type_other     :string(255)
#  auth_status_code    :integer         not null
#  auth_status_other   :string(255)
#  transaction_type    :string(36)
#  created_at          :datetime
#  updated_at          :datetime
#

# Table for types of forms used to obtain authorizations from the Participant.
class ParticipantAuthorizationForm < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :auth_form_id

  belongs_to :participant
  belongs_to :contact
  belongs_to :provider
  
  belongs_to :psu,            :conditions => "list_name = 'PSU_CL1'",             :foreign_key => :psu_code,            :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :auth_form_type, :conditions => "list_name = 'AUTH_FORM_TYPE_CL1'",  :foreign_key => :auth_form_type_code, :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :auth_status,    :conditions => "list_name = 'AUTH_STATUS_CL1'",     :foreign_key => :auth_status_code, :class_name => 'NcsCode', :primary_key => :local_code
  
end
