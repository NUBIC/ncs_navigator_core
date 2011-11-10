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
    
    def new_event_for_person(person)
      list_name   = NcsCode.attribute_lookup(:event_type_code)
      ets         = person.upcoming_events.collect { |e| PatientStudyCalendar.map_psc_segment_to_mdes_event_type(e) }
      event_types = NcsCode.where("list_name = ? AND display_text in (?)", list_name, ets).all
      Event.new(:participant => person.participant, :event_type => event_types.first)
    end
  
end
