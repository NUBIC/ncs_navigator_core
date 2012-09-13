# -*- coding: utf-8 -*-

require 'ncs_navigator/configuration'

class ContactsController < ApplicationController
  before_filter :set_event_id

  # GET /contacts/new
  # GET /contacts/new.json
  def new
    @person  = Person.find(params[:person_id])
    @contact = Contact.start(@person, :psu_code => NcsNavigatorCore.psu_code, :contact_date_date => Date.today, :contact_start_time => Time.now.strftime("%H:%M"))

    @event = event_for_person(false)
    @requires_consent = @person.participant && @person.participant.consented? == false && @event.event_type.display_text != "Pregnancy Screener"

    respond_to do |format|
      format.html # new.html.haml
      format.json  { render :json => @contact }
    end
  end

  # POST /contacts
  # POST /contacts.json
  def create
    @person  = Person.find(params[:person_id])
    @contact = Contact.start(@person, params[:contact])

    @event = event_for_person

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
    @contact.set_default_end_time

    if params[:next_event]
      if @person.participant.pending_events.count > 0
        @event = @person.participant.pending_events.first
      else
        @event = event_for_person
      end
      link = find_or_create_contact_link
      redirect_to(select_instrument_contact_link_path(link))
    else
      @contact_link = ContactLink.where("contact_id = ? AND person_id = ?", @contact.id, @person.id).first
      @event = @contact_link.event
      set_disposition_group
    end
  end

  def update
    @person  = Person.find(params[:person_id])
    @contact = Contact.find(params[:id])

    @contact_link = ContactLink.where("contact_id = ? AND person_id = ?", @contact.id, @person.id).first
    @event = @contact_link.event

    respond_to do |format|
      if @contact.update_attributes(params[:contact])
        link = find_or_create_contact_link

        format.html { redirect_to(post_update_redirect_path(link), :notice => 'Contact was successfully updated.') }
        format.json { render :json => @contact }
      else
        set_disposition_group
        format.html { render :action => "new" }
        format.json { render :json => @contact.errors }
      end
    end
  end

  def post_update_redirect_path(link)
    if link && link.provider
      contact_log_provider_path(link.provider)
    else
      select_instrument_contact_link_path(link)
    end
  end
  private :post_update_redirect_path

  def provider_recruitment
    @disposition_group = DispositionMapper::PROVIDER_RECRUITMENT_EVENT
    @event    = Event.find(params[:event_id])
    @provider = Provider.find(params[:provider_id])
    if request.get?
      # set defaults on contact
      @contact = Contact.new(:psu_code => NcsNavigatorCore.psu_code,
                             :who_contacted_code => 8,    # provider
                             :contact_location_code => 3, # provider office
                             :contact_date_date => Date.today,
                             :contact_start_time => Time.now.strftime("%H:%M"))
    else
      @contact = Contact.new(params[:contact])
    end
    if request.post?
      if params[:person_id].blank?
        flash[:warning] = "Contact requires the person who was contacted."
        render :action => "provider_recruitment"
      else
        # determine person contacted from select list
        @person = Person.find(params[:person_id])

        if @contact.save
          # set the event disposition to that of the contact
          @event.update_attribute(:event_disposition, @contact.contact_disposition)
          link = find_or_create_contact_link
          redirect_to post_recruitment_contact_provider_path(@provider, :contact_id => @contact.id)
        else
          render :action => "provider_recruitment"
        end
      end
    end
  end

  private

    # TODO: remove call to new_event_for_person
    def event_for_person(save = true)
      if @event_id.to_i > 0
        event = Event.find(@event_id)
      else
        event = new_event_for_person(@person, params[:event_type_id])
      end
      event.save! if save
      event
    end

    def set_event_id
      @event_id = params[:event_id] if params[:event_id]
    end

    def find_or_create_contact_link
      link = ContactLink.where("contact_id = ? AND person_id = ? AND event_id = ?",
                                @contact, @person, @event).first
      if link.blank?
        link = ContactLink.create(:contact => @contact,
                                  :person => @person,
                                  :event => @event,
                                  :provider => @provider,
                                  :staff_id => current_staff_id,
                                  :psu_code => NcsNavigatorCore.psu_code)
      end
      link
    end

        ##
    # Determine the disposition group to be used from the contact type or instrument taken
    def set_disposition_group
      @disposition_group = nil
      if @event
        set_disposition_group_for_event
      else
        set_disposition_group_for_contact_link
      end
    end

end