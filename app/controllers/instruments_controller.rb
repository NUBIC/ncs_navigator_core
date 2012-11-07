# -*- coding: utf-8 -*-


class InstrumentsController < ApplicationController

 ##
 # Displays the form for the Instrument record
  def edit
    @instrument = Instrument.find(params[:id])
  end

  ##
  # Updates the Instrument record
  # Afterwards redirects the user to the participant or person page
  def update
    @instrument   = Instrument.find(params[:id])
    @person       = @instrument.person
    @participant  = @person.participant

    respond_to do |format|
      if @instrument.update_attributes(params[:instrument])

        redirect_path = @participant ? participant_path(@participant) : person_path(@person)

      	format.html { redirect_to(redirect_path, :notice => 'Instrument was successfully updated.') }
        format.json { render :json => @instrument }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @instrument.errors, :status => :unprocessable_entity }
      end
    end
  end

end


