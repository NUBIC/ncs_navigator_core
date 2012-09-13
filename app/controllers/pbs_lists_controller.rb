# -*- coding: utf-8 -*-

require 'ncs_navigator/core/pbs/pbs_list_importer'

class PbsListsController < ApplicationController

  def index
    params[:page] ||= 1

    params[:q] ||= Hash.new
    params[:q]['s'] ||= "provider_name_practice asc"
    @q = PbsList.search(params[:q])
    @pbs_lists = @q.result.paginate(:page => params[:page], :per_page => 20)

    respond_to do |format|
      format.html
      format.json { render :json => @q.result.all }
    end
  end

  def edit
    @pbs_list = PbsList.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render :json => @pbs_list }
    end
  end

  def show
    @pbs_list = PbsList.find(params[:id])
    @provider = @pbs_list.provider
    @staff = []
    PersonnelProviderLink.where(:provider_id => @provider).all.each { |ppl| @staff << ppl.person }
    respond_to do |format|
      format.html
      format.json { render :json => @pbs_list }
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

    mark_pbs_list_as_having_started_recruitment(@pbs_list)

    event = @pbs_list.provider.provider_recruitment_event
    if event.blank?
      event = Event.create!(:event_type_code => 22,
                            :event_disposition_category_code => 7,
                            :event_start_date => Date.today,
                            :event_start_time => Time.now.strftime('%H:%M'))
    end
    redirect_to provider_recruitment_contacts_path(:provider_id => @pbs_list.provider, :event_id => event)
  end

  def mark_pbs_list_as_having_started_recruitment(pbs_list)
    attrs = {
      :pr_recruitment_start_date => Date.today,
      :pr_recruitment_status_code => 3
    }
    pbs_list.update_attributes(attrs) unless pbs_list.recruitment_started?
  end
  private :mark_pbs_list_as_having_started_recruitment

end
