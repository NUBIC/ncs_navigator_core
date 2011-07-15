require File.expand_path('../../../config/initializers/system_configuration', __FILE__)

class ApplicationController < ActionController::Base
  protect_from_forgery

  APP_VERSION = "0.0.1"
  
  before_filter :set_system_defaults

  private
  
    def set_system_defaults
      @psu_code = SystemConfiguration.psu_code
    end
  
end
