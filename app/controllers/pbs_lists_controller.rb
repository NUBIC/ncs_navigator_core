# -*- coding: utf-8 -*-

require 'ncs_navigator/core/pbs/pbs_list_importer'

class PbsListsController < ApplicationController

  def index
    params[:page] ||= 1

    params[:q] ||= Hash.new
    params[:q]['s'] ||= "provider_name_practice asc"
    params[:q]['in_sample_code_eq'] ||= 1
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
    @contact_links = @provider.contact_links.joins(:contact).order(:contact_date, :created_at).reverse_order
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

        redirect_path = params["redirect_to"].blank? ? edit_pbs_list_path(@pbs_list) : params["redirect_to"]

        format.html { redirect_to(redirect_path) }
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
      event = Event.create!(:event_type_code => Provider::PROVIDER_RECRUIMENT_EVENT_TYPE_CODE,
                            :event_disposition_category_code => 7)
    end
    redirect_to provider_recruitment_contacts_path(:provider_id => @pbs_list.provider, :event_id => event)
  end

  def mark_pbs_list_as_having_started_recruitment(pbs_list)
    if !pbs_list.recruitment_started? && !pbs_list.provider_recruited?
      pbs_list.update_attribute(:pr_recruitment_status_code, 3)
    end
  end
  private :mark_pbs_list_as_having_started_recruitment

end
