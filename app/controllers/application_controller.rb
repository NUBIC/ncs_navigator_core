require 'ncs_navigator/configuration'

class ApplicationController < ActionController::Base
  include Aker::Rails::SecuredController
  protect_from_forgery
  
  helper_method :psc
  
  before_filter :set_system_defaults

  protected
  
    def psc
      @psc ||= PatientStudyCalendar.new(current_user)
    end

  private
  
    def set_system_defaults
      @psu_code = NcsNavigatorCore.psu
    end
    
    def current_staff
      current_user.username
    end
  
end
