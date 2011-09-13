class ContactLinksController < ApplicationController
	
	# GET /contact_links/1/edit
	def edit
		@contact_link = ContactLink.find(params[:id])
		
		@response_set = @contact_link.response_set
		
		# TODO: remove Pregnancy Screener check
		if @response_set.blank? && @contact_link.person.upcoming_events.select { |e| e.to_s.include?('Pregnancy Screener') }.empty?
			redirect_to select_instrument_contact_link_path(@contact_link)
		else
		  # TODO: remove checks for missing Surveys
			@person				= @contact_link.person
			@survey				= @response_set.blank? ? nil : @response_set.survey 
		
			if @contact_link.instrument.blank? && @survey
				instrument = create_instrument(@survey)
				@contact_link.instrument = instrument
				@contact_link.save!
			end
		end
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
				format.html { redirect_to(select_instrument_contact_link_path(@contact_link), :notice => 'Contact was successfully updated.') }
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
	
	private
	
		def create_instrument(survey)
			Instrument.create(:psu_code => @psu_code, 
												:instrument_version => InstrumentEventMap.version(survey.title),
												:instrument_type => InstrumentEventMap.instrument_type(survey.title))
		end
	
end