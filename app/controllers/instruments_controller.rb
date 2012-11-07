# -*- coding: utf-8 -*-


class InstrumentsController < ApplicationController

##
 # Displays the form for the Instrument record
 # Posts the form to the finalize_instrument path
  def edit
    @instrument   = Instrument.find(params[:id])
    @person       = @instrument.person
    @participant  = @person.participant
    @response_set = @instrument.response_set
    @survey       = @response_set.survey
  end

  ##
  # Updates the Instrument record
  # Afterwards redirects the user to the /contact_links/:id/decision_page
  def update
    @instrument   = Instrument.find(params[:id])
    @person       = @instrument.person
    @participant  = @person.participant

    respond_to do |format|
      if @instrument.update_attributes(params[:instrument])

      	format.html { redirect_to(participant_path(@participant), :notice => 'Instrument was successfully updated.') }
        format.json { render :json => @instrument }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @instrument.errors, :status => :unprocessable_entity }
      end
    end
  end

end


