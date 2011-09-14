require 'ncs_navigator/mdes'
require 'ncs_navigator/configuration'

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
    
  end
end

