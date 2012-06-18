# -*- coding: utf-8 -*-

require 'ncs_navigator/core/pbs/pbs_list_importer'

class PbsListsController < ApplicationController

  def index
    params[:page] ||= 1

    @q = PbsList.search(params[:q])
    result = @q.result(:distinct => true).order("pbs_list_id DESC")
    @pbs_lists = result.paginate(:page => params[:page], :per_page => 20)

    respond_to do |format|
      format.html
      format.json { render :json => result.all }
    end
  end

  def new
    if params[:provider_id]

      @provider = Provider.find(params[:provider_id])
      @pbs_list = PbsList.new(:provider => @provider, :psu_code => @psu_code)

      respond_to do |format|
        format.html
        format.json { render :json => @pbs_list }
      end
    else
      flash[:warning] = "Provider is required when creating a PBS List record."
      redirect_to pbs_lists_path
    end
  end

  def edit
    @pbs_list = PbsList.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render :json => @pbs_list }
    end
  end

  def create
    @pbs_list = PbsList.new(params[:pbs_list])

    respond_to do |format|
      if @pbs_list.save
        flash[:notice] = 'PBS List Record was successfully created.'
        format.html { redirect_to(edit_pbs_list_path(@pbs_list)) }
        format.json  { render :json => @pbs_list }
      else
        format.html { render :action => "new" }
        format.json  { render :json => @pbs_list.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @pbs_list = PbsList.find(params[:id])

    respond_to do |format|
      if @pbs_list.update_attributes(params[:pbs_list])
        flash[:notice] = 'PBS List Record was successfully updated.'
        format.html { redirect_to(edit_pbs_list_path(@pbs_list)) }
        format.json  { render :json => @pbs_list }
      else
        format.html { render :action => "edit" }
        format.json  { render :json => @pbs_list.errors, :status => :unprocessable_entity }
      end
    end
  end

  def upload
    if request.post?
      if params[:file].blank?
        flash.now[:warning] = "You must select a file to upload."
        render :action => "upload"
      else
        PbsListImporter.import_data(params[:file].open)
        flash[:notice] = "Data was successfully uploaded."
        redirect_to pbs_lists_path
      end
    end
  end

  def sample_upload_file
    send_file "#{Rails.root}/app/views/pbs_lists/sample_pbs_list_upload_file.csv", :type => 'text/csv'
  end

  def recruit_provider
    @pbs_list = PbsList.find(params[:id])
    @pbs_list.update_attribute(:pr_recruitment_start_date, Date.today) unless @pbs_list.recruitment_started?
    event = @pbs_list.provider.provider_recruitment_event
    if event.blank?
      event = Event.create!(:event_type_code => 22,
                           :event_start_date => Date.today,
                           :event_start_time => Time.now.strftime('%H:%M'))
    end
    redirect_to staff_list_provider_path(@pbs_list.provider, :event_id => event.id)
  end

end
