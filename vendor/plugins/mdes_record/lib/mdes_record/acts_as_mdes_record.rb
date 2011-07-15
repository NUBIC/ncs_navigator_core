require 'active_support/concern'
module MdesRecord
  extend ActiveSupport::Concern
  
  included do
    before_create :set_public_id
    before_validation :set_missing_in_error
  end
 
  module ClassMethods

    def acts_as_mdes_record(options = {})
      send :include, InstanceMethods
      cattr_accessor :public_id_field
      self.public_id_field = (options[:public_id_field] || :uuid)
    end

  end
 
  module InstanceMethods

    def set_public_id
      self.send("#{self.public_id_field}=", UUID.new.generate) if self.uuid.blank?
    end
    
    def public_id
      self.send("#{self.public_id_field}")
    end
    
    def uuid
      self.send("#{self.public_id_field}")      
    end

    # If an NCS Code is missing, default the selection to 'Missing in Error' whose local_code value is -4
    def set_missing_in_error
      self.class.reflect_on_all_associations.each do |association|
        if association.options[:class_name] == "NcsCode" && self.send(association.name.to_sym).blank?
          missing_in_error_code = NcsCode.where("#{association.options[:conditions]} AND local_code = -4").first
          self.send("#{association.name}=", missing_in_error_code)
        end
      end
    end
    
  end
  
end