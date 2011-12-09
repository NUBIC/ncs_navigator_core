class ContactLinksController < ApplicationController
	
	# GET /contact_links/1/edit
	def edit
		@contact_link = ContactLink.find(params[:id])
		@event        = @contact_link.event
		@instrument   = @contact_link.instrument
		@response_set = @instrument.response_set if @instrument 
	  
		# TODO: remove Pregnancy Screener check
		if params[:close_contact].blank? && @response_set.blank? && @contact_link.person.upcoming_events.select { |e| e.to_s.include?('Pregnancy Screener') }.empty?
			redirect_to select_instrument_contact_link_path(@contact_link)
		else
			@person	 = @contact_link.person
			@contact = @contact_link.contact
			@survey	 = @response_set.survey if @response_set
		  
		  @contact.set_language_and_interpreter_data(@person)
      @contact.populate_post_survey_attributes(@instrument)
      
      @event.populate_post_survey_attributes(@contact, @response_set)
      @event.event_repeat_key = @person.event_repeat_key(@event)
		end
		
		set_time_and_dates
		set_disposition_group
	end

	# PUT /contact_links/1
	# PUT /contact_links/1.json
	def update
		@contact_link = ContactLink.find(params[:id])

		respond_to do |format|

			if @contact_link.update_attributes(params[:contact_link]) && 
				 @contact_link.event.update_attributes(params[:event]) &&
				 # @contact_link.instrument.update_attributes(params[:instrument]) &&
				 @contact_link.contact.update_attributes(params[:contact])
				
				# TODO: remove instrument check when all Instruments are created
				@contact_link.instrument.update_attributes(params[:instrument]) if @contact_link.instrument
				
				# TODO: determine redirect after updating 
				# format.html { redirect_to(select_instrument_contact_link_path(@contact_link), :notice => 'Contact was successfully updated.') }
				format.html { redirect_to(person_path(@contact_link.person), :notice => 'Contact was successfully updated.') }
				format.json { head :ok }
			else
				format.html { render :action => "edit" }
				format.json { render :json => @contact_link.errors, :status => :unprocessable_entity }
			end
		end
	end
	
	def select_instrument
		@contact_link = ContactLink.find(params[:id])
		@contact			= @contact_link.contact
		@person				= @contact_link.person
		@participant	= @person.participant
		@event				= @contact_link.event
	end
	
	def edit_instrument
		@contact_link = ContactLink.find(params[:id])
		
		@person				= @contact_link.person
		
    @instrument   = find_or_create_instrument(@survey)
		@response_set = @instrument.response_set
		@survey				= @response_set.survey

  	set_instrument_time_and_date(@contact_link.contact)
  	
    @instrument.instrument_repeat_key = @person.instrument_repeat_key(@instrument.survey)
    @instrument.set_instrument_breakoff(@response_set)    
    
    @contact_link.contact.set_language_and_interpreter_data(@person)
    @contact_link.contact.populate_post_survey_attributes(@instrument)
	end
	
	def finalize_instrument
		@contact_link = ContactLink.find(params[:id])

		respond_to do |format|
			if @contact_link.instrument.update_attributes(params[:instrument])
				format.html { redirect_to(edit_contact_link_path(@contact_link), :notice => 'Instrument was successfully updated.') }
				format.json { head :ok }
			else
				format.html { render :action => "edit" }
				format.json { render :json => @contact_link.errors, :status => :unprocessable_entity }
			end
		end
	 
	end
	
	private
	
	  def set_time_and_dates
	    contact = @contact_link.contact
	   	contact.contact_end_time = Time.now.strftime("%H:%M")
	   	set_event_time_and_date(contact)
	   	set_instrument_time_and_date(contact)
	  end
	  
	  def set_event_time_and_date(contact)
	   	event = @contact_link.event
	   	if event
	   	  start_date = contact.contact_date_date.nil? ? Date.today : contact.contact_date_date
  	   	event.event_start_date = start_date if event.event_start_date.blank?
  	   	event.event_end_date = Date.today
  	   	event.event_start_time = contact.contact_start_time
  	   	event.event_end_time = contact.contact_end_time
	   	end
	  end
	  
	  def set_instrument_time_and_date(contact)
	   	instrument = @contact_link.instrument
	   	if instrument
  	   	instrument.instrument_start_date = instrument.created_at.to_date
  	   	instrument.instrument_end_date = Date.today
  	   	instrument.instrument_start_time = instrument.created_at.strftime("%H:%M")
  	   	instrument.instrument_end_time = Time.now.strftime("%H:%M")
  		end
	  end

	  
	  def find_or_create_instrument(survey)
      @contact_link.instrument
	  end
	  
	  ##
	  # Determine the disposition group to be used from the contact type or instrument taken
	  def set_disposition_group
	    @disposition_group = nil
	    instrument = @contact_link.instrument
	    contact = @contact_link.contact
	    if contact && contact.contact_type
	      @disposition_group = @contact_link.contact.contact_type.to_s
      end
      if instrument && instrument.survey
        case instrument.survey.title
        when /_HHEnum_/
          @disposition_group = instrument.survey.title
        when /_PregScreen_/
          @disposition_group = instrument.survey.title
        end
      end
	  end
	
end