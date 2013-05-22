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
      @psc ||= PatientStudyCalendar.new(current_user, NcsNavigatorCore.psc_logger)
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

    # Used by contacts and contact_links controller

    ##
    # Disposition group based on specific events
    def set_disposition_group_for_event
      if @contact.multiple_unique_events_for_contact?
        @disposition_group = DispositionMapper::GENERAL_STUDY_VISIT_EVENT
        return
      end

      case @event.event_type_code
      when Event.pregnancy_screener_code
        @disposition_group = DispositionMapper::PREGNANCY_SCREENER_EVENT
      when Event.informed_consent_code
        @disposition_group = disposition_group_for_study_arm(@event)
      when Event.low_intensity_data_collection_code
        @disposition_group = disposition_group_for_study_arm(@event)
      when Event.low_to_high_conversion_code
        @disposition_group = disposition_group_for_study_arm(@event)
      when Event.provider_recruitment_code
        @disposition_group = DispositionMapper::PROVIDER_RECRUITMENT_EVENT
      when Event.pbs_eligibility_screener_code
        @disposition_group = DispositionMapper::PBS_ELIGIBILITY_EVENT
      else
        set_disposition_group_for_contact_link
      end
    end

    def disposition_group_for_study_arm(event)
      event.try(:participant).low_intensity? ? DispositionMapper::TELEPHONE_INTERVIEW_EVENT : set_disposition_group_for_contact_link
    end
    private :disposition_group_for_study_arm


    ##
    # Default logic for setting of disposition group
    def set_disposition_group_for_contact_link
      instrument = @contact_link.instrument
      contact    = @contact_link.contact

      if contact && contact.contact_type_code.to_i > 0
        @disposition_group = @contact_link.contact.contact_type.to_s
      elsif instrument && instrument.survey.try(:title)
        @disposition_group = instrument.survey.title
      else
        @disposition_group = DispositionMapper::GENERAL_STUDY_VISIT_EVENT
      end
    end

    # @param contact_info [Address, Email, Telephone]
    def contact_info_redirect_path(contact_info)
      person = contact_info.person
      if person.nil?
        return edit_polymorphic_url(contact_info)
      end
      person.participant? ? participant_path(person.participant) : person_path(person)
    end

    def ransack_paginate(model)
      q = model.search(params[:q])
      selects = q.sorts.map{|sort| "\"#{sort.parent.table_name}\".\"#{sort.attr_name}\""}
      q.sorts = 'id'
      page = q.result(:distinct => true)
        .select(selects)
        .paginate(:page => params[:page], :per_page => 20)
      [q, page]
    end
end
