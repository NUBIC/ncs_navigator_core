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

    # TODO: delete this method - events should be created as placeholder methods via Event.schedule_and_create_placeholder
    def new_event_for_person(person, event_type_id = nil)
      list_name   = NcsCode.attribute_lookup(:event_type_code)
      if event_type_id
        event_types = NcsCode.where("list_name = ? AND id in (?)", list_name, event_type_id).all
      else
        ets         = person.upcoming_events.collect { |e| PatientStudyCalendar.map_psc_segment_to_mdes_event_type(e) }
        event_types = NcsCode.where("list_name = ? AND display_text in (?)", list_name, ets).all
      end
      Event.new(:participant => person.participant, :event_type => event_types.first, :psu_code => NcsNavigatorCore.psu_code, :event_start_date => Date.today)
    end

end
