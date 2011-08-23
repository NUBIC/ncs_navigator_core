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
