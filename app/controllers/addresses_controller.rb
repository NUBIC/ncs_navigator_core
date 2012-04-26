# -*- coding: utf-8 -*-

class AddressesController < ApplicationController

  def index
    params[:page] ||= 1

    @q = Address.search(params[:q])
    result = @q.result(:distinct => true)
    @addresses = result.paginate(:page => params[:page], :per_page => 20)

    respond_to do |format|
      format.html
      format.json { render :json => result.all }
    end
  end

  def show
    @address = Address.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render :json => @address }
    end
  end

  def new
    @address = Address.new
    if params[:person_id]
      @person = Person.find(params[:person_id])
      @address.person = @person
    end

    respond_to do |format|
      format.html
      format.json { render :json => @address }
    end
  end

  def edit
    @address = Address.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render :json => @address }
    end
  end

  def create
    @address = Address.new(params[:address])

    respond_to do |format|
      if @address.save
        path = edit_address_path(@address)
        if @address.person
          path = @address.person.participant? ? participant_path(@address.person.participant) : person_path(@address.person)
        end
        flash[:notice] = 'Address was successfully created.'
        format.html { redirect_to(path) }
        format.json  { render :json => @address }
      else
        format.html { render :action => "new" }
        format.json  { render :json => @address.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @address = Address.find(params[:id])

    respond_to do |format|
      if @address.update_attributes(params[:address])
        flash[:notice] = 'Address was successfully updated.'
        format.html { redirect_to(edit_address_path(@address)) }
        format.json  { render :json => @address }
      else
        format.html { render :action => "edit" }
        format.json  { render :json => @address.errors, :status => :unprocessable_entity }
      end
    end
  end

end