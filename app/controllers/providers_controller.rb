# -*- coding: utf-8 -*-

class ProvidersController < ApplicationController

  def index
    params[:page] ||= 1

    @q = Provider.search(params[:q])
    result = @q.result(:distinct => true)
    @providers = result.paginate(:page => params[:page], :per_page => 20)

    respond_to do |format|
      format.html
      format.json { render :json => result.all }
    end
  end

  def new
    @provider = Provider.new(:psu_code => @psu_code, :provider_info_date => Date.today)
    @provider.provider_info_update = Date.today

    respond_to do |format|
      format.html
      format.json { render :json => @provider }
    end
  end

  def edit
    @provider = Provider.find(params[:id])
    @provider.provider_info_update = Date.today

    respond_to do |format|
      format.html
      format.json { render :json => @provider }
    end
  end

  def create
    @provider = Provider.new(params[:provider])

    respond_to do |format|
      if @provider.save
        flash[:notice] = 'Provider was successfully created.'
        format.html { redirect_to(edit_provider_path(@provider)) }
        format.json  { render :json => @provider }
      else
        format.html { render :action => "new" }
        format.json  { render :json => @provider.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @provider = Provider.find(params[:id])

    respond_to do |format|
      if @provider.update_attributes(params[:provider])
        flash[:notice] = 'Provider was successfully updated.'
        format.html { redirect_to(edit_provider_path(@provider)) }
        format.json  { render :json => @provider }
      else
        format.html { render :action => "edit" }
        format.json  { render :json => @provider.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit_contact_information
    @provider = Provider.find(params[:id])
    if @provider.address.blank?
      @provider.build_address(:psu_code => @psu_code)
    end
    if @provider.telephone.blank?
      @provider.telephones.build(:psu_code => @psu_code, :phone_type => Telephone.work_phone_type)
    end
    if @provider.fax.blank?
      @provider.telephones.build(:psu_code => @psu_code, :phone_type => Telephone.fax_phone_type)
    end
    if @provider.primary_contact.blank?
      staff = @provider.staff.build(:psu_code => @psu_code)
      staff.emails.build(:psu_code => @psu_code)
      staff.telephones.build(:psu_code => @psu_code, :phone_type => Telephone.work_phone_type)
    end

    respond_to do |format|
      format.html
      format.json { render :json => @provider }
    end
  end

  def update_contact_information
    @provider = Provider.find(params[:id])

    respond_to do |format|
      if @provider.update_attributes(params[:provider])

        if params[:save_primary_contact] && !@provider.staff.blank?
          pc = @provider.personnel_provider_links.where(:person_id => @provider.staff.first.id).first
          pc.update_attribute(:primary_contact, true) unless pc.blank?
        end

        flash[:notice] = 'Provider contact information was successfully updated.'
        format.html { redirect_to(edit_contact_information_provider_path(@provider)) }
        format.json  { render :json => @provider }
      else
        format.html { render :action => "edit" }
        format.json  { render :json => @provider.errors, :status => :unprocessable_entity }
      end
    end
  end

  def staff_list
    @provider = Provider.find(params[:id])
    @event = Event.find(params[:event_id]) if params[:event_id]
  end

end
