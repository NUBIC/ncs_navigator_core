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

    @email.email_info_date = Date.today
    @email.email_info_update = Date.today

    respond_to do |format|
      format.html
      format.json { render :json => @email }
    end
  end

  def create
    @person = Person.find(params[:person_id])
    @email = Email.new(params[:email])

    respond_to do |format|
      if @email.save
        path = @person.participant? ? participant_path(@person.participant) : person_path(@person)
        flash[:notice] = 'Email was successfully created.'
        format.html { redirect_to(path) }
        format.json  { render :json => @email }
      else
        format.html { render :action => "new" }
        format.json  { render :json => @email.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @person = Person.find(params[:person_id])
    @email = Email.find(params[:id])

    respond_to do |format|
      if @email.update_attributes(params[:email])
        path = @person.participant? ? participant_path(@person.participant) : person_path(@person)
        flash[:notice] = 'Email was successfully updated.'
        format.html { redirect_to(path) }
        format.json  { render :json => @email }
      else
        format.html { render :action => "edit" }
        format.json  { render :json => @email.errors, :status => :unprocessable_entity }
      end
    end
  end

end
