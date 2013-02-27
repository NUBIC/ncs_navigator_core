# -*- coding: utf-8 -*-


class TelephonesController < ApplicationController

  def new
    @person = Person.find(params[:person_id])
    @telephone = Telephone.new
    @telephone.person = @person
    @telephone.phone_info_date = Date.today
    @telephone.phone_info_update = Date.today

    respond_to do |format|
      format.html
      format.json { render :json => @telephone }
    end
  end

  def edit
    @person = Person.find(params[:person_id])
    @telephone = Telephone.find(params[:id])

    @telephone.phone_info_date = Date.today
    @telephone.phone_info_update = Date.today

    respond_to do |format|
      format.html
      format.json { render :json => @telephone }
    end
  end

  def create
    @telephone = Telephone.new(params[:telephone])
    respond_to do |format|
      if @telephone.save
        flash[:notice] = 'Telephone was successfully created.'
        format.html { redirect_to(contact_info_redirect_path(@telephone)) }
        format.json  { render :json => @telephone }
      else
        format.html { render :action => "new" }
        format.json  { render :json => @telephone.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @telephone = Telephone.find(params[:id])
    respond_to do |format|
      if @telephone.update_attributes(params[:telephone])
        flash[:notice] = 'Telephone was successfully updated.'
        format.html { redirect_to(contact_info_redirect_path(@telephone)) }
        format.json  { render :json => @telephone }
      else
        format.html { render :action => "edit" }
        format.json  { render :json => @telephone.errors, :status => :unprocessable_entity }
      end
    end
  end

end
