# == Schema Information
# Schema version: 20111205213437
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
  
  TELEPHONE_CONTACT_CODE = 3
  MAILING_CONTACT_CODE   = 2
  
  belongs_to :psu,                      :conditions => "list_name = 'PSU_CL1'",                 :foreign_key => :psu_code,                      :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :contact_type,             :conditions => "list_name = 'CONTACT_TYPE_CL1'",        :foreign_key => :contact_type_code,             :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :contact_language,         :conditions => "list_name = 'LANGUAGE_CL2'",            :foreign_key => :contact_language_code,         :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :contact_interpret,        :conditions => "list_name = 'TRANSLATION_METHOD_CL3'",  :foreign_key => :contact_interpret_code,        :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :contact_location,         :conditions => "list_name = 'CONTACT_LOCATION_CL1'",    :foreign_key => :contact_location_code,         :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :contact_private,          :conditions => "list_name = 'CONFIRM_TYPE_CL2'",        :foreign_key => :contact_private_code,          :class_name => 'NcsCode', :primary_key => :local_code  
  belongs_to :who_contacted,            :conditions => "list_name = 'CONTACTED_PERSON_CL1'",    :foreign_key => :who_contacted_code,            :class_name => 'NcsCode', :primary_key => :local_code  

  has_many :contact_links
  has_many :instruments, :through => :contact_links
  
  ##
  # An event is 'closed' or 'completed' if the disposition has been set.
  # @return [true, false]  
  def closed?
    contact_disposition.to_i > 0
  end
  alias completed? closed?
  alias complete? closed?

  ##
  # Given a person, determine the langugage and interpreter value used during the 
  # instruments taken.
  # This method assumes that the contact took place in the same language/interpreter
  # as the initial instrument taken
  # @param [Person]
  def set_language_and_interpreter_data(person)
    set_language(person)
    set_interpreter(person)
  end
  
  ##
  # Given an instrument, presumably after the instrument has been administered, set attributes on the
  # contact that can be inferred based on the instrument and type of contact
  # @param [Instrument]
  # @param [ResponseSet]
  def populate_post_survey_attributes(instrument = nil, response_set = nil)
    
    # TODO: determine if the response_set for the instrument has been completed
    if instrument
      self.who_contacted = NcsCode.for_attribute_name_and_local_code(:who_contacted_code, 1)
    end
    
    case contact_type.to_i
    when TELEPHONE_CONTACT_CODE, MAILING_CONTACT_CODE
      self.contact_location = NcsCode.for_attribute_name_and_local_code(:contact_location_code, 2) 
      self.contact_private  = NcsCode.for_attribute_name_and_local_code(:contact_private_code, 1)
      self.contact_private_detail = contact_type.to_s
      self.contact_distance = 0.0
    else
    end
    
    if response_set && (contact_language || contact_language_other)
      
    end
  end
  
  private
  
    def set_language(person)
      english_response = person.responses_for(PregnancyScreenerOperationalDataExtractor::ENGLISH).last
      
      if english_response && english_response.to_s == "Yes"
        self.contact_language = NcsCode.for_list_name_and_local_code('LANGUAGE_CL2', english_response.answer.reference_identifier)
        return
      end
      
      language_response = person.responses_for(PregnancyScreenerOperationalDataExtractor::CONTACT_LANG).last
      if language_response && language_response.answer.reference_identifier.to_i > 0
        language_response_value = NcsCode.for_list_name_and_local_code('LANGUAGE_CL5', language_response.answer.reference_identifier)
        self.contact_language = NcsCode.for_list_name_and_display_text('LANGUAGE_CL2', language_response_value.to_s)
        return
      end
      
      other_language_response = person.responses_for(PregnancyScreenerOperationalDataExtractor::CONTACT_LANG_OTH).last
      self.contact_language_other = other_language_response.to_s if other_language_response
      
    end
    
    def set_interpreter(person)
      interpreter_response = person.responses_for(PregnancyScreenerOperationalDataExtractor::INTERPRET).last
      
      if interpreter_response && interpreter_response.to_s == "No"
        self.contact_interpret = NcsCode.for_list_name_and_local_code('TRANSLATION_METHOD_CL3', -3)
        return
      end

      interpreter_response = person.responses_for(PregnancyScreenerOperationalDataExtractor::CONTACT_INTERPRET).last
      if interpreter_response && interpreter_response.answer.reference_identifier.to_i > 0
        self.contact_interpret = NcsCode.for_list_name_and_local_code('TRANSLATION_METHOD_CL3', interpreter_response.answer.reference_identifier)
        return
      end

      other_interpreter_response = person.responses_for(PregnancyScreenerOperationalDataExtractor::CONTACT_INTERPRET_OTH).last
      self.contact_interpret_other = other_interpreter_response.to_s if other_interpreter_response
      
    end
end
