# -*- coding: utf-8 -*-

require 'ncs_navigator/configuration'

class ParticipantVisitConsentsController < ApplicationController

  # GET /participant_visit_consents/new
  # GET /participant_visit_consents/new.json
  def new
    @contact_link = ContactLink.find(params[:contact_link_id])
    # TODO: raise exception if no ContactLink
    @participant = @contact_link.event.participant
    # What to do if the participant does not exist ?
    @participant_visit_consent = ParticipantVisitConsent.new(:contact_link => @contact_link,
                                                             :contact => @contact_link.contact,
                                                             :vis_person_who_consented => @contact_link.person,
                                                             :participant => @participant)
    respond_to do |format|
      format.html # new.html.haml
      format.json  { render :json => @participant_visit_consent }
    end
  end

  # GET /participant_visit_consents/edit
  # GET /participant_visit_consents/edit.json
  def edit
    @participant_visit_consent = ParticipantVisitConsent.find(params[:id])
    respond_to do |format|
      format.html # edit.html.haml
      format.json  { render :json => @participant_visit_consent }
    end
  end

  def create
    @participant_visit_consent = ParticipantVisitConsent.new(params[:participant_visit_consent])

    respond_to do |format|
      if @participant_visit_consent.save
        flash[:notice] = 'Participant Visit Consent was successfully created.'
        format.html { redirect_to(decision_page_contact_link_path(@participant_visit_consent.contact_link)) }
        format.json  { render :json => @participant_visit_consent }
      else
        format.html { render :action => "new" }
        format.json  { render :json => @participant_visit_consent.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @participant_visit_consent = ParticipantVisitConsent.find(params[:id])

    respond_to do |format|
      if @participant_visit_consent.update_attributes(params[:participant_visit_consent])
        flash[:notice] = 'Participant Visit Consent was successfully updated.'
        format.html { redirect_to(decision_page_contact_link_path(@participant_visit_consent.contact_link)) }
        format.json  { render :json => @participant_visit_consent }
      else
        format.html { render :action => "edit" }
        format.json  { render :json => @participant_visit_consent.errors, :status => :unprocessable_entity }
      end
    end
  end

end