class ContactsController < ApplicationController

  # GET /contacts/new
  # GET /contacts/new.json
  def new
    @person     = Person.find(params[:person_id])
    @contact    = Contact.new(:psu_code =>  @psu_code)
    
    event_for_contact

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
    
    event_for_contact
    @event.save!

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
    
    @contact_link = ContactLink.where("contact_id = ? AND person_id = ?", @contact, @person).first
    @event = @contact_link.event
  end
  
  def update
    @person  = Person.find(params[:person_id])
    @contact = Contact.find(params[:id])
    
    event_for_contact
    @event.save!

    respond_to do |format|
      if @contact.update_attributes(params[:contact])
        link = find_or_create_contact_link
        
        format.html { redirect_to(select_instrument_contact_link_path(link), :notice => 'Contact was successfully created.') }
        format.json { render :json => @contact }
      else
        format.html { render :action => "new" }
        format.json { render :json => @contact.errors }
      end
    end
  end
  
  private
  
    def event_for_contact
      list_name   = NcsCode.attribute_lookup(:event_type_code)
      event_types = NcsCode.where("list_name = ? AND display_text in (?)", list_name, Event.event_types(@person.upcoming_events)).all
      @event      = Event.new(:participant => @person.participant, :event_type => event_types.first)
    end
    
    def find_or_create_contact_link
      link = ContactLink.where("contact_id = ? AND person_id = ?", @contact, @person).first
      if link.blank?
        link = ContactLink.create(:contact => @contact, :person => @person, :event => @event, :staff_id => "TODO - staff id", :psu_code => @psu_code)
      end
      link
    end
  
  
end