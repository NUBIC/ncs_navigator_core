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


end
