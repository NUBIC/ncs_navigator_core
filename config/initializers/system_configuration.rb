require 'ncs_navigator/mdes'
require 'ncs_navigator/configuration'

##
# Uses the ncs_navigator_configuration gem to pull these values
# cf. /etc/nubic/ncs/navigator.ini 
module NcsNavigatorCore
  
  class << self
    
    def footer_left_logo_path
      NcsNavigator.configuration.footer_logo_left.to_s.split("/").last if NcsNavigator.configuration.footer_logo_left
    end
    
    def footer_right_logo_path
      NcsNavigator.configuration.footer_logo_right.to_s.split("/").last if NcsNavigator.configuration.footer_logo_right
    end
    
    def psu
      NcsNavigator.configuration.psus.first.id unless NcsNavigator.configuration.psus.blank?
    end
    alias :psu_code :psu
    
    def study_center_name
      NcsNavigator.configuration.core['study_center_name']
    end
    
    def study_center_phone_number
      NcsNavigator.configuration.core['study_center_phone_number']
    end
    
    ##
    # One of the following:
    # PB - Provider Based
    # EH - Enhanced Household
    # HILI - Hi/Lo
    def recruitment_type
      NcsNavigator.configuration.core['recruitment_type']
    end
    
    def with_specimens
      NcsNavigator.configuration.core['with_specimens']      
    end
    
  end
end

