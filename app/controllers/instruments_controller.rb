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
    #if @response_set
    #set_instrument_time_and_date(@contact_link.contact)

    #@instrument.instrument_repeat_key = @person.instrument_repeat_key(@instrument.survey)
    #@instrument.set_instrument_breakoff(@response_set)
    #if @instrument.instrument_type.blank? || @instrument.instrument_type_code <= 0
    #  @instrument.instrument_type = InstrumentEventMap.instrument_type(@survey.try(:title))
    #end
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
   

  