# -*- coding: utf-8 -*-

class ParticipantConsentsController < ApplicationController

  # GET /participant_consents/1/edit
  def edit
    @participant_consent = ParticipantConsent.find(params[:id])
    @contact_link = ContactLink.find(params[:contact_link_id]) unless params[:contact_link_id].blank?
    @participant = @participant_consent.participant
    @contact = @participant_consent.contact

    if @participant_consent.response_set
      response_set = @participant_consent.response_set
    else
      response_set = @participant_consent.associate_response_set
    end

    redirect_to surveyor.edit_my_survey_path(
      :survey_code => response_set.survey.access_code,
      :response_set_code => response_set.access_code)
  end

end
