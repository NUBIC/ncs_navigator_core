class AddressesController < ApplicationController

  def new
    @person = Person.find(params[:person_id])
    @address = Address.new

    respond_to do |format|
      format.html
      format.json { render :json => @address }
    end
  end

  def edit
    @person = Person.find(params[:person_id])
    @address = Address.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render :json => @address }
    end
  end

  def create
    @person = Person.find(params[:person_id])
    @address = Address.new(params[:address])

    respond_to do |format|
      if @address.save
        path = @person.participant? ? participant_path(@person.participant) : person_path(@person)
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
    @person = Person.find(params[:person_id])
    @address = Address.find(params[:id])

    respond_to do |format|
      if @address.update_attributes(params[:address])
        path = @person.participant? ? participant_path(@person.participant) : person_path(@person)
        flash[:notice] = 'Address was successfully updated.'
        format.html { redirect_to(path) }
        format.json  { render :json => @address }
      else
        format.html { render :action => "edit" }
        format.json  { render :json => @address.errors, :status => :unprocessable_entity }
      end
    end
  end

end
