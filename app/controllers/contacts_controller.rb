# -*- coding: utf-8 -*-

require 'ncs_navigator/configuration'
require 'ncs_navigator/authorization'
class ContactsController < ApplicationController
  before_filter :set_event_id
  before_filter :set_staff_list

  permit Role::SYSTEM_ADMINISTRATOR, Role::USER_ADMINISTRATOR, Role::ADMINISTRATIVE_STAFF, Role::STAFF_SUPERVISOR,
    :only => [:destroy]

  # GET /contacts/new
  # GET /contacts/new.json
  def new
    @person  = Person.find(params[:person_id])
    @contact = Contact.start(@person,
                             :psu_code => NcsNavigatorCore.psu_code,
                             :contact_date_date => Date.today,
                             :contact_start_time => Time.now.strftime("%H:%M"))
    @event = event_for_person

    if @event
      @requires_consent = (@person.participant &&
                              (@person.participant.consented? == false) &&
                              !@event.screener_event?)
    end

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
        if @event
          format.html { redirect_to(select_instrument_contact_link_path(link.id), :notice => 'Contact was successfully created.') }
        else
          format.html { redirect_to(@person, :notice => 'Contact was successfully created.') }
        end
        format.json { render :json => @contact }
      else
        format.html { render :action => "new" }
        format.json { render :json => @contact.errors }
      end
    end
  end

  # GET /contact/1/edit
  def edit
    @contact_link = ContactLink.find(params[:contact_link_id])
    @person       = @contact_link.person

    @contact = Contact.find(params[:id])
    @contact.set_default_end_time

    if params[:next_event]
      if @person.participant.pending_events.count > 0
        @event = @person.participant.pending_events.first
      else
        @event = event_for_person
      end
      redirect_to(select_instrument_contact_link_path(find_or_create_contact_link))
    else
      @event = @contact_link.event
      set_disposition_group
    end
  end

  def update
    @contact_link = ContactLink.find(params[:contact_link_id])
    @person       = @contact_link.person
    @contact      = Contact.find(params[:id])
    @event        = @contact_link.event

    respond_to do |format|
      if @contact.update_attributes(params[:contact])
        format.html { post_update_redirect_path(@contact_link)}
        format.json { render :json => @contact }
      else
        set_disposition_group
        format.html { render :action => "edit" }
        format.json { render :json => @contact.errors }
      end
    end
  end

  def post_update_redirect_path(link)
    if link && link.provider
      if link.provider.pbs_list
        link.provider.pbs_list.update_recruitment_dates!
        link.provider.pbs_list.update_recruitment_status!
      end
      redirect_path = link.provider.pbs_list ? pbs_list_path(link.provider.pbs_list) : pbs_lists_path
      notice = "Contact for #{link.provider} was successfully updated."
    elsif link.event
      redirect_path = decision_page_contact_link_path(link)
    elsif @person.participant
      redirect_path = participant_path(@person.participant)
    else
      redirect_path = contact_links_path
    end
    notice ||= "Contact was successfully updated."
    redirect_to(redirect_path, :notice => notice)
  end
  private :post_update_redirect_path

  def provider_recruitment
    @disposition_group = DispositionMapper::PROVIDER_RECRUITMENT_EVENT
    @event    = Event.find(params[:event_id])
    @provider = Provider.find(params[:provider_id])
    if request.get?
      # set defaults on contact
      disp = @provider.recruited? ? DispositionMapper::PROVIDER_RECRUITED.to_s : nil
      @contact = Contact.new(:psu_code => NcsNavigatorCore.psu_code,
                             :contact_disposition => disp,
                             :who_contacted_code => 8,    # provider
                             :contact_location_code => 3, # provider office
                             :contact_date_date => Date.today,
                             :contact_start_time => Time.now.strftime("%H:%M"))
    end
    if request.post?
      @contact = Contact.new(params[:contact])
      if params[:person_id].blank?
        flash[:warning] = "Contact requires the person who was contacted."
        render :action => "provider_recruitment"
      else
        # determine person contacted from select list
        @person = Person.find(params[:person_id])

        if @contact.save
          link = find_or_create_contact_link

          update_provider_recruitment_event(@event, @contact)
          @provider.pbs_list.update_recruitment_dates!
          @provider.pbs_list.update_recruitment_status!

          # check if the provider was recruited
          # if so update the pbs_list cooperation date
          # and redirect to provider logistics page
          if @contact.contact_disposition == DispositionMapper::PROVIDER_RECRUITED
            @provider.pbs_list.mark_recruited!
            flash[:notice] = "Provider has been marked recruited."
            redirect_to recruited_provider_path(@provider, :contact_id => @contact.id)
          elsif DispositionMapper::PROVIDER_REFUSED.include? @contact.contact_disposition
            @provider.pbs_list.mark_refused!
            flash[:warning] = "Provider has been marked as refused. Please provide reason for refusal."
            redirect_to new_provider_non_interview_provider_path(@provider, :contact_id => @contact.id, :refusal => true)
          else
            flash[:notice] = "Contact for #{@provider} was successfully created."
            redirect_path = @provider.pbs_list ? pbs_list_path(@provider.pbs_list) : pbs_lists_path
            redirect_to redirect_path
          end
        else
          render :action => "provider_recruitment"
        end
      end
    end
  end

  def destroy
    @contact = Contact.find(params[:id])
    @contact.contact_links.each { |cl| cl.destroy }
    @contact.destroy

    if params[:pbs_list_id]
      pbs_list = PbsList.find(params[:pbs_list_id])
      pbs_list.update_recruitment_dates!
      pbs_list.update_recruitment_status!
    end

    respond_to do |format|
      flash[:notice] = "Contact was deleted."
      url = pbs_list.nil? ? contact_links_path : pbs_list_path(pbs_list)
      format.html { redirect_to(url) }
      format.xml  { head :ok }
    end
  end

  private

    def update_provider_recruitment_event(event, contact)
      event_attrs = {}
      # set the event disposition to that of the contact
      # unless the event disposition is Provider Recruited
      if event.event_disposition.to_i != DispositionMapper::PROVIDER_RECRUITED
        event_attrs[:event_disposition] = contact.contact_disposition
      end
      if event.event_start_date.blank?
        event_attrs[:event_start_date] = contact.contact_date_date
      end
      if event.event_start_time.blank?
        event_attrs[:event_start_time] = contact.contact_start_time
      end
      event.update_attributes(event_attrs) unless event_attrs.blank?
    end

    ##
    # Find event by given event id or
    # determine next event from the person cf. next_event_for_person
    #
    # By the way:
    # => 0
    # ...so a nil event_id will result in calling `next_event_for_person`
    #
    # an event_id of -1 is used to indicate "eventless contact"
    def event_for_person
      event = case params[:event_id].to_i
        when -1 then nil
        when  0 then next_event_for_person
        else Event.find(params[:event_id])
      end
    end

    ##
    # If person.participant exists use that participant's next pending event
    # or schedule that event if that does not exist.
    # If we get to this point and there is no participant for this person,
    # raise an exception.
    def next_event_for_person
      if participant = @person.participant
        if participant.pending_events.blank?
          Event.schedule_and_create_placeholder(psc, participant)
          participant.events.reload
        end
        participant.pending_events.first
      end
    end

    def set_event_id
      @event_id = params[:event_id]
    end

    def set_staff_list
      @current_staff_id = current_staff_id
      begin
        if usrs = NcsNavigator::Authorization::Core::Authority.new.find_users
          @staff_list = usrs.map{ |u| [u.full_name, u.identifiers[:staff_id]] }
        end
      rescue
        # NOOP - will not show proxy list and will default to current logged in user
      end
    end

    def find_or_create_contact_link
      link = ContactLink.where("contact_id = ? AND person_id = ? AND event_id = ?",
                                @contact, @person, @event).first

      staff_id = params["staff_id"].blank? ? current_staff_id : params["staff_id"]

      if link.blank?
        link = ContactLink.create(:contact => @contact,
                                  :person => @person,
                                  :event => @event,
                                  :provider => @provider,
                                  :staff_id => staff_id,
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
