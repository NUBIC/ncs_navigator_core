# -*- coding: utf-8 -*-


require 'ncs_navigator/configuration'

class ApplicationController < ActionController::Base
  include Aker::Rails::SecuredController
  protect_from_forgery

  helper_method :psc, :recruitment_strategy, :display_staff_info

  before_filter :set_system_defaults

  ##
  # Save the current_user [Aker::User] username
  # in the versions whodunnit field for auditing
  # cf. https://github.com/airblade/paper_trail
  def user_for_paper_trail
    current_username
  end

  protected

    def psc
      @psc ||= PatientStudyCalendar.new(current_user)
    end

    def recruitment_strategy
      NcsNavigatorCore.recruitment_strategy
    end

  private

    def set_system_defaults
      @psu_code = NcsNavigatorCore.psu
    end

    def current_username
      current_user ? current_user.username : 'unknown'
    end

    def current_staff_id
      current_user.identifiers[:staff_id] || 'unknown_staff_id'
    end

    def display_staff_info
      "#{current_user.full_name} (#{current_staff_id})"
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

    # Used by contacts and contact_links controller

    ##
    # Disposition group based on specific events
    def set_disposition_group_for_event
      case @event.event_type.to_s
      when "Pregnancy Screener"
        @disposition_group = DispositionMapper::PREGNANCY_SCREENER_EVENT
      when "Informed Consent"
        @disposition_group = disposition_group_for_study_arm(@event)
      when "Low Intensity Data Collection"
        @disposition_group = disposition_group_for_study_arm(@event)
      when "Low to High Conversion"
        contact = @contact_link.contact
        if contact && contact.contact_type
          @disposition_group = @contact_link.contact.contact_type.to_s
        else
          @disposition_group = DispositionMapper::GENERAL_STUDY_VISIT_EVENT
        end
      when "Provider-Based Recruitment"
        @disposition_group = DispositionMapper::PROVIDER_RECRUITMENT_EVENT
      else
        set_disposition_group_for_contact_link
      end
    end

    def disposition_group_for_study_arm(event)
      event.try(:participant).low_intensity? ? DispositionMapper::TELEPHONE_INTERVIEW_EVENT : DispositionMapper::GENERAL_STUDY_VISIT_EVENT
    end
    private :disposition_group_for_study_arm

    ##
    # Default logic for setting of disposition group
    def set_disposition_group_for_contact_link
      # First check if the event category was selected
      if @event.event_disposition_category_code.to_i > 0
        @disposition_group =
          DispositionMapper.for_event_disposition_category_code(
            @event.event_disposition_category_code)
      # otherwise choose from the contact or instrument
      else
        instrument = @contact_link.instrument
        contact = @contact_link.contact
        if contact && contact.contact_type
          @disposition_group = @contact_link.contact.contact_type.to_s
        end
        if instrument && instrument.survey
          @disposition_group = instrument.survey.title
        end
      end
    end

end