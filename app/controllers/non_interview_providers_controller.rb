# -*- coding: utf-8 -*-

class NonInterviewProvidersController < ApplicationController

  # GET /providers/:provider_id/non_interview_providers/new
  # GET /providers/:provider_id/non_interview_providers/new.json
  def new
    @contact  = Contact.find(params[:contact_id])
    @provider = Provider.find(params[:provider_id])

    @non_interview_provider = NonInterviewProvider.new(:psu_code => NcsNavigatorCore.psu_code, :contact => @contact, :provider => @provider)

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @non_interview_provider }
    end
  end

  # GET /providers/:provider_id/non_interview_providers/:id/edit
  def edit
    @non_interview_provider = NonInterviewProvider.find(params[:id])
    @contact  = Contact.find(params[:contact_id])
    @provider = @non_interview_provider.provider
  end

  # POST /providers/:provider_id/non_interview_providers/new
  # POST /providers/:provider_id/non_interview_providers/new.json
  def create

    @contact  = Contact.find(params[:contact_id])
    @provider = Provider.find(params[:provider_id])

    @non_interview_provider = NonInterviewProvider.new(params[:non_interview_provider])
    @non_interview_provider.contact  = @contact
    @non_interview_provider.provider = @provider

    respond_to do |format|
      if @non_interview_provider.save
        format.html { redirect_to edit_provider_path(@provider.id), :notice => 'Non-Interview Provider Report was successfully created.' }
        format.json { render :json => @non_interview_provider, :status => :created, :location => @non_interview_provider }
      else
        format.html { render :action => "new" }
        format.json { render :json => @non_interview_provider.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /providers/:provider_id/non_interview_providers/:id
  # PUT /providers/:provider_id/non_interview_providers/:id.json
  def update
    @non_interview_provider = NonInterviewProvider.find(params[:id])

    respond_to do |format|
      if @non_interview_provider.update_attributes(params[:non_interview_provider])
        format.html { redirect_to edit_provider_path(@non_interview_provider.provider_id), :notice => 'Non-Interview Provider Report was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @non_interview_provider.errors, :status => :unprocessable_entity }
      end
    end
  end
end