require 'ncs_navigator/configuration'

class ApplicationController < ActionController::Base
  include Aker::Rails::SecuredController
  protect_from_forgery
    
  before_filter :set_system_defaults

  private
  
    def set_system_defaults
      @psu_code = NcsNavigatorCore.psu
    end
    
    def current_staff
      current_user.username
    end
  
end
