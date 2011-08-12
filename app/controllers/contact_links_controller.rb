class ContactLinksController < ApplicationController
  
  # GET /contact_links/1/edit
  def edit
    @contact_link = ContactLink.find(params[:id])
    
    @response_set = @contact_link.response_set
    
    @person       = @contact_link.person
    @survey       = @response_set.survey
    
    @contact_link.instrument ||= Instrument.new
  end

  # PUT /contact_links/1
  # PUT /contact_links/1.json
  def update
    @contact_link = ContactLink.find(params[:id])

    respond_to do |format|
      if @contact_link.update_attributes(params[:contact_link]) && 
         @contact_link.instrument.update_attributes(params[:instrument]) &&
         @contact_link.event.update_attributes(params[:event]) &&
         @contact_link.event.update_attributes(params[:event])
        format.html { redirect_to(contact_links_path, :notice => 'Contact was successfully updated.') }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @contact_link.errors, :status => :unprocessable_entity }
      end
    end
  end
  
end