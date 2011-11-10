# == Schema Information
# Schema version: 20111110015749
#
# Table name: contacts
#
#  id                      :integer         not null, primary key
#  psu_code                :integer         not null
#  contact_id              :string(36)      not null
#  contact_disposition     :integer
#  contact_type_code       :integer         not null
#  contact_type_other      :string(255)
#  contact_date            :string(10)
#  contact_date_date       :date
#  contact_start_time      :string(255)
#  contact_end_time        :string(255)
#  contact_language_code   :integer         not null
#  contact_language_other  :string(255)
#  contact_interpret_code  :integer         not null
#  contact_interpret_other :string(255)
#  contact_location_code   :integer         not null
#  contact_location_other  :string(255)
#  contact_private_code    :integer         not null
#  contact_private_detail  :string(255)
#  contact_distance        :decimal(6, 2)
#  who_contacted_code      :integer         not null
#  who_contacted_other     :string(255)
#  contact_comment         :text
#  transaction_type        :string(255)
#  created_at              :datetime
#  updated_at              :datetime
#

# Staff makes Contact with a Person pursuant to a protocol – either one 
# of the recruitment schemas or a Study assessment protocol. 
# The scope of a Contact may include one or more Events, one or more
# Instruments in an Event and one or more Specimens that some Instruments collect.
class Contact < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :contact_id, :date_fields => [:contact_date]
  
  belongs_to :psu,                      :conditions => "list_name = 'PSU_CL1'",                 :foreign_key => :psu_code,                      :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :contact_type,             :conditions => "list_name = 'CONTACT_TYPE_CL1'",        :foreign_key => :contact_type_code,             :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :contact_language,         :conditions => "list_name = 'LANGUAGE_CL2'",            :foreign_key => :contact_language_code,         :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :contact_interpret,        :conditions => "list_name = 'TRANSLATION_METHOD_CL3'",  :foreign_key => :contact_interpret_code,        :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :contact_location,         :conditions => "list_name = 'CONTACT_LOCATION_CL1'",    :foreign_key => :contact_location_code,         :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :contact_private,          :conditions => "list_name = 'CONFIRM_TYPE_CL2'",        :foreign_key => :contact_private_code,          :class_name => 'NcsCode', :primary_key => :local_code  
  belongs_to :who_contacted,            :conditions => "list_name = 'CONTACTED_PERSON_CL1'",    :foreign_key => :who_contacted_code,            :class_name => 'NcsCode', :primary_key => :local_code  

  ##
  # An event is 'closed' or 'completed' if the disposition has been set.
  # @return [true, false]  
  def closed?
    contact_disposition.to_i > 0
  end
  alias completed? closed?
  alias complete? closed?
  
end
