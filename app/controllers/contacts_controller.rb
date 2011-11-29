require 'ncs_navigator/configuration'

class ContactsController < ApplicationController

  # GET /contacts/new
  # GET /contacts/new.json
  def new
    @person     = Person.find(params[:person_id])
    @contact    = Contact.new(:psu_code => NcsNavigatorCore.psu_code, :contact_date_date => Date.today, :contact_start_time => Time.now.strftime("%H:%M"))

    event_for_person(false)
    @requires_consent = @person.participant && @person.participant.consented? == false && @event.event_type.display_text != "Pregnancy Screener"

    respond_to do |format|
      format.html # new.html.haml
      format.json  { render :json => @contact }
    end
  end

  # POST /contacts
  # POST /contacts.json
  def create
    @person     = Person.find(params[:person_id])
    @contact    = Contact.new(params[:contact])
    
    event_for_person

    respond_to do |format|
      if @contact.save
        link = find_or_create_contact_link
        
        format.html { redirect_to(select_instrument_contact_link_path(link), :notice => 'Contact was successfully created.') }
        format.json { render :json => @contact }
      else
        format.html { render :action => "new" }
        format.json { render :json => @contact.errors }
      end
    end
  end
  
  # GET /contact/1/edit
  def edit
    @person  = Person.find(params[:person_id])
    @contact = Contact.find(params[:id])
    @contact.contact_end_time = Time.now.strftime("%H:%M")

    if params[:next_event]
      event_for_person(false)
    else
      @contact_link = ContactLink.where("contact_id = ? AND person_id = ?", @contact.id, @person.id).first
      @event = @contact_link.event
    end
  end
  
  def update
    @person  = Person.find(params[:person_id])
    @contact = Contact.find(params[:id])
    
    if params[:next_event]
      event_for_person
    else
      @event = @contact.contact_link.event
    end

    respond_to do |format|
      if @contact.update_attributes(params[:contact])
        link = find_or_create_contact_link
        
        format.html { redirect_to(select_instrument_contact_link_path(link), :notice => 'Contact was successfully updated.') }
        format.json { render :json => @contact }
      else
        format.html { render :action => "new" }
        format.json { render :json => @contact.errors }
      end
    end
  end
  
  private
  
    def event_for_person(save = true)
      @event = new_event_for_person(@person, params[:event_type_id])
      @event.save! if save
    end
    
    def find_or_create_contact_link
      link = ContactLink.where("contact_id = ? AND person_id = ? AND event_id = ?", @contact, @person, @event).first
      if link.blank?
        link = ContactLink.create(:contact => @contact, :person => @person, :event => @event, :staff_id => current_staff, :psu_code => NcsNavigatorCore.psu_code)
      end
      link
    end
  
  
end