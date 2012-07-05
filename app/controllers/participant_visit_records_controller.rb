# -*- coding: utf-8 -*-


require 'ncs_navigator/configuration'

class ParticipantVisitRecordsController < ApplicationController

  # GET /participant_visit_records/new
  # GET /participant_visit_records/new.json
  def new
    @contact_link = ContactLink.find(params[:contact_link_id])
    # TODO: raise exception if no ContactLink
    @participant = @contact_link.event.participant
    # What to do if the participant does not exist ?
    @participant_visit_record = ParticipantVisitRecord.new(:contact => @contact_link.contact,
                                                           :rvis_person => @contact_link.person,
                                                           :participant => @participant)
    respond_to do |format|
      format.html # new.html.haml
      format.json  { render :json => @participant_visit_record }
    end
  end

  # GET /participant_visit_records/edit
  # GET /participant_visit_records/edit.json
  def edit
    @contact_link = ContactLink.find(params[:contact_link_id])
    # TODO: raise exception if no ContactLink
    @participant_visit_record = ParticipantVisitRecord.find(params[:id])
    respond_to do |format|
      format.html # edit.html.haml
      format.json  { render :json => @participant_visit_record }
    end
  end

  def create
    @participant_visit_record = ParticipantVisitRecord.new(params[:participant_visit_record])

    respond_to do |format|
      if @participant_visit_record.save
        flash[:notice] = 'Participant Visit Record (RVIS) was successfully created.'
        format.html { redirect_to(decision_page_contact_link_path(params[:contact_link_id])) }
        format.json  { render :json => @participant_visit_record }
      else
        format.html { render :action => "new" }
        format.json  { render :json => @participant_visit_record.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @participant_visit_record = ParticipantVisitRecord.find(params[:id])

    respond_to do |format|
      if @participant_visit_record.update_attributes(params[:participant_visit_record])
        flash[:notice] = 'Participant Visit Record (RVIS) was successfully updated.'
        format.html { redirect_to(decision_page_contact_link_path(params[:contact_link_id])) }
        format.json  { render :json => @participant_visit_record }
      else
        format.html { render :action => "edit" }
        format.json  { render :json => @participant_visit_record.errors, :status => :unprocessable_entity }
      end
    end
  end

end