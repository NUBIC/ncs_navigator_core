# -*- coding: utf-8 -*-


class NonInterviewReportsController < ApplicationController

  before_filter :set_contact_link_associations

  # GET /non_interview_reports/new
  # GET /non_interview_reports/new.json
  def new
    @non_interview_report = NonInterviewReport.new(:psu_code => NcsNavigatorCore.psu_code,
      :contact => @contact, :person => @person)

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @non_interview_report }
    end
  end

  # GET /non_interview_reports/1/edit
  def edit
    @non_interview_report = NonInterviewReport.find(params[:id])
  end

  # POST /non_interview_reports
  # POST /non_interview_reports.json
  def create
    @non_interview_report = NonInterviewReport.new(params[:non_interview_report])

    respond_to do |format|
      if @non_interview_report.save
        format.html { redirect_to edit_contact_link_path(@contact_link.id, :close_contact => true), :notice => 'Non-Interview Report was successfully created.' }
        format.json { render :json => @non_interview_report, :status => :created, :location => @non_interview_report }
      else
        format.html { render :action => "new" }
        format.json { render :json => @non_interview_report.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /non_interview_reports/1
  # PUT /non_interview_reports/1.json
  def update
    @non_interview_report = NonInterviewReport.find(params[:id])

    respond_to do |format|
      if @non_interview_report.update_attributes(params[:non_interview_report])
        format.html { redirect_to decision_page_contact_link_path(@contact_link), :notice => 'Non-Interview Report was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @non_interview_report.errors, :status => :unprocessable_entity }
      end
    end
  end

  private

    def set_contact_link_associations
      # TODO: what to do in case of no contact_link_id
      @contact_link = ContactLink.find(params[:contact_link_id])
      @contact			= @contact_link.contact
  		@person				= @contact_link.person
  		@participant	= @person.participant if @person
  		@event				= @contact_link.event
    end

end