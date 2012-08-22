# -*- coding: utf-8 -*-
#
#

class SurveyorController < ApplicationController
  include Surveyor::SurveyorControllerMethods
  layout 'surveyor'

  ##
  # Copied from Surveyor::SurveyorControllerMethods
  #
  # Required change in order to handle the breaking off of a
  # survey at any point in a single or multi-part survey
  # cf. params[:breakoff] or params[:finish]
  def update
    saved = false
    ActiveRecord::Base.transaction do
      @response_set = ResponseSet.find_by_access_code(params[:response_set_code], :include => {:responses => :answer}, :lock => true)
      unless @response_set.blank?
        saved = @response_set.update_attributes(:responses_attributes => ResponseSet.to_savable(params[:r]))
        @response_set.complete! if saved && user_ended_survey?
        saved &= @response_set.save
      end
    end
    return redirect_to(surveyor_finish(params[:breakoff])) if saved && user_ended_survey?

    respond_to do |format|
      format.html do
        if @response_set.blank?
          return redirect_with_message(available_surveys_path, :notice, t('surveyor.unable_to_find_your_responses'))
        else
          flash[:notice] = t('surveyor.unable_to_update_survey') unless saved
          redirect_to edit_my_survey_path(:anchor => anchor_from(params[:section]), :section => section_id_from(params[:section]))
        end
      end
      format.js do
        ids, remove, question_ids = {}, {}, []
        ResponseSet.trim_for_lookups(params[:r]).each do |k,v|
          v[:answer_id].reject!(&:blank?) if v[:answer_id].is_a?(Array)
          ids[k] = @response_set.responses.find(:first, :conditions => v, :order => "created_at DESC").id if !v.has_key?("id")
          remove[k] = v["id"] if v.has_key?("id") && v.has_key?("_destroy")
          question_ids << v["question_id"]
        end
        render :json => {"ids" => ids, "remove" => remove}.merge(@response_set.reload.all_dependencies(question_ids))
      end
    end
  end

  ##
  # Did user send params :finish or :breakoff?
  def user_ended_survey?
    params[:finish] || params[:breakoff]
  end

  ##
  # Overridden from Surveyor::SurveyorControllerMethods
  # to handle Operational Data Extraction and to determine
  # whether or not this is a part of a multi-part survey
  def surveyor_finish(breakoff = false)
    set_activity_plan_for_participant

    contact_link = @response_set.instrument.contact_link

    if @activity_plan.final_survey_part?(@response_set) || breakoff
      # go to contact_link.edit_instrument
      update_participant_based_on_survey(@response_set)
      edit_instrument_contact_link_path(contact_link.id)
    else
      # go to next part of the survey
      activity = @activity_plan.current_scheduled_activity(contact_link.event.to_s, @response_set)
      survey = Survey.most_recent_for_access_code(Survey.to_normalized_string(activity.instrument))
      start_instrument_person_path(@response_set.person,
                                   :participant_id => activity.participant.id,
                                   :references_survey_access_code => activity.references.to_s,
                                   :survey_access_code => survey.access_code,
                                   :contact_link_id => contact_link.id)
    end
  end

  def render_context
    set_activity_plan_for_participant
    build_instrument_context
  end

  ##
  # Piggy-back on the render_context callback from SurveyorControllerMethods
  # to ensure that we have the response_set object for this
  def set_activity_plan_for_participant
    @participant          = @response_set.participant
    @instrument           = @response_set.instrument
    @event                = @instrument.event
    @activities_for_event = []
    if @participant
      @activity_plan        = psc.build_activity_plan(@participant)
      @activities_for_event = @activity_plan.activities_for_event(@event.to_s)
    end
  end

  ##
  # Create and return InstrumentContext object associated with the current user
  def build_instrument_context
    ctxt = NcsNavigator::Core::Mustache::InstrumentContext.new(@response_set)
    ctxt.current_user = current_user
    ctxt
  end

  private

    # TODO: ensure that the state transitions are based on the responses in the response set
    #       and that the disposition of the instrument was completed
    def update_participant_based_on_survey(response_set)
      participant = response_set.participant
      if participant
        participant.update_state_after_survey(response_set, psc)
      end
    end
end
