# -*- coding: utf-8 -*-


class EmailsController < ApplicationController

  def new
    @person = Person.find(params[:person_id])
    @email = Email.new
    @email.person = @person

    @email.email_info_date = Date.today
    @email.email_info_update = Date.today

    respond_to do |format|
      format.html
      format.json { render :json => @email }
    end
  end

  def edit
    @person = Person.find(params[:person_id])
    @email = Email.find(params[:id])

    @email.email_info_date = @email.created_at.to_date if @email.email_info_date.blank?
    @email.email_info_update = Date.today

    respond_to do |format|
      format.html
      format.json { render :json => @email }
    end
  end

  def create
    @email = Email.new(params[:email])
    respond_to do |format|
      if @email.save
        flash[:notice] = 'Email was successfully created.'
        format.html { redirect_to(contact_info_redirect_path(@email)) }
        format.json  { render :json => @email }
      else
        format.html { render :action => "new" }
        format.json  { render :json => @email.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @email = Email.find(params[:id])
    respond_to do |format|
      if @email.update_attributes(params[:email])
        flash[:notice] = 'Email was successfully updated.'
        format.html { redirect_to(contact_info_redirect_path(@email)) }
        format.json  { render :json => @email }
      else
        format.html { render :action => "edit" }
        format.json  { render :json => @email.errors, :status => :unprocessable_entity }
      end
    end
  end

end
