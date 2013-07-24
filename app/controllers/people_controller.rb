# -*- coding: utf-8 -*-


class PeopleController < ApplicationController

  layout proc { |controller| controller.request.xhr? ? nil : 'application'  }

  permit Role::SYSTEM_ADMINISTRATOR, Role::USER_ADMINISTRATOR, Role::ADMINISTRATIVE_STAFF, Role::STAFF_SUPERVISOR, :only => [:index]

  before_filter :set_participant, :only => [:new, :edit, :create, :update]

  # GET /people
  # GET /people.json
  def index
    params[:page] ||= 1

    @q, @people = ransack_paginate(Person)

    respond_to do |format|
      format.html # index.html.haml
    end
  end

  def events_and_contact_links
    rows = @person.events +
           @person.contact_links.select{ |cl| !@person.events.include?(cl.event) }
    if @person && @participant
      rows += @participant.events +
              @person.contact_links.collect(&:event) +
              @person.contact_links.select {|cl| cl.event.nil?}
    end
    rows.compact.uniq.flatten
  end
  private :events_and_contact_links

  # GET /people/1
  def show
    @person = Person.includes(:contact_links, :events).find(params[:id])
    @participant = @person.participant
    @events_and_contact_links = events_and_contact_links

    redirect_to participant_path(@participant) if @participant
  end

  # GET /people/1/provider_staff_member
  def provider_staff_member
    @member = Person.find(params[:id])
    @provider = Provider.find(params[:provider_id])
  end

  # GET /people/1/provider_staff_member_radio_button
  def provider_staff_member_radio_button
    @member = Person.find(params[:id])
    @provider = Provider.find(params[:provider_id])
  end

  # GET /people/new
  # GET /people/new.json
  def new
    @person = Person.new
    set_person_attribute_defaults(@person)
    @provider = Provider.find(params[:provider_id]) unless params[:provider_id].blank?
    if @provider
      @person.person_provider_links.build(:psu_code => @psu_code,
                                          :provider => @provider,
                                          :person   => @person,
                                          :is_active_code => 1)
      @person.sampled_persons_ineligibilities.build(:psu_code => @psu_code,
                                                    :person => @person,
                                                    :provider => @provider)
    end

    respond_to do |format|
      format.html # new.html.haml
      format.json  { render :json => @person }
    end
  end

  # POST /people
  # POST /people.json
  def create
    filter_sampled_persons_ineligibilties

    @person = Person.new(params[:person])
    @provider = Provider.find(params[:provider_id]) unless params[:provider_id].blank?

    respond_to do |format|
      if @person.save
        create_relationship_to_participant

        path = people_path
        msg  = 'Person was successfully created.'
        if @provider
          path = provider_path(@provider)
          msg  = "Person was successfully created for #{@provider}."
        end
        format.html { redirect_to(path, :notice => msg) }
        format.json { render :json => @person }
      else
        format.html { render :action => "new" }
        format.json { render :json => @person.errors }
      end
    end
  end

  def filter_sampled_persons_ineligibilties
    if spi_attrs = params[:person]["sampled_persons_ineligibilities_attributes"]
      if first_spi_attr = spi_attrs["0"]
        if first_spi_attr["age_eligible_code"].blank? &&
           first_spi_attr["county_of_residence_code"].blank? &&
           first_spi_attr["first_prenatal_visit_code"].blank? &&
           first_spi_attr["pregnancy_eligible_code"].blank?
          params[:person].delete("sampled_persons_ineligibilities_attributes")
        end
      end
    end
  end

  # GET /people/1/edit
  def edit
    @person = Person.find(params[:id])
    set_person_attribute_defaults(@person)
    if @participant
      ppl = ParticipantPersonLink.where(:participant_id => @participant.id, :person_id => @person.id).first
      @relationship_code = ppl.relationship_code if ppl
    end
    @provider = Provider.find(params[:provider_id]) unless params[:provider_id].blank?
  end

  # PUT /people/1
  # PUT /people/1.json
  def update
    @person = Person.find(params[:id])
    @provider = Provider.find(params[:provider_id]) unless params[:provider_id].blank?

    respond_to do |format|
      if @person.update_attributes(params[:person])

        path = people_path
        msg  = 'Person was successfully updated.'
        if @provider
          path = provider_path(@provider)
          msg  = "Person was successfully updated for #{@provider}."
        end

        format.html { redirect_to(path, :notice => msg) }
        format.json { render :json => @person }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @person.errors, :status => :unprocessable_entity }
      end
    end
  end

  # GET /people/new_child
  def new_child
    @person = Person.new
    set_person_attribute_defaults(@person, true)
    @participant = Participant.find(params[:participant_id])
    @contact_link = ContactLink.find(params[:contact_link_id])
    @relationship_code = '8'
    respond_to do |format|
      format.html # new.html.haml
      format.json  { render :json => @person }
    end
  end

  # POST /people/create_child
  def create_child
    @participant = Participant.find(params[:participant_id])
    @contact_link = ContactLink.find(params[:contact_link_id])

    respond_to do |format|
      if @participant.create_child_person_and_participant!(params[:person])

        path = decision_page_contact_link_path(@contact_link)
        msg  = 'Child was successfully created.'

        format.html { redirect_to(path, :notice => msg) }
        format.json { render :json => @person }
      else
        format.html { render :action => "new_child" }
        format.json { render :json => @person.errors }
      end
    end
  end

  # GET /people/:id/edit_child
  def edit_child
    @person = Person.find(params[:id])
    set_person_attribute_defaults(@person, true)
    @participant = Participant.find(params[:participant_id])
    @contact_link = ContactLink.find(params[:contact_link_id])
    @relationship_code = '8'
    respond_to do |format|
      format.html # new.html.haml
      format.json  { render :json => @person }
    end
  end

  # PUT /people/:id/update_child
  def update_child
    @person = Person.find(params[:id])
    @participant = Participant.find(params[:participant_id])
    @contact_link = ContactLink.find(params[:contact_link_id])

    respond_to do |format|
      if @person.update_attributes(params[:person])

        path = decision_page_contact_link_path(@contact_link)
        msg  = 'Child was successfully updated.'

        format.html { redirect_to(path, :notice => msg) }
        format.json { render :json => @person }
      else
        format.html { render :action => "edit_child" }
        format.json { render :json => @person.errors }
      end
    end
  end


  # GET /people/1/start_instrument
  def start_instrument
    # get information from params
    person = Person.find(params[:id])
    participant = Participant.find(params[:participant_id])
    instrument_survey = Survey.most_recent_for_access_code(params[:references_survey_access_code])
    current_survey = Survey.most_recent_for_access_code(params[:survey_access_code])

    # determine event
    cl = person.contact_links.includes(:event, :contact).find(params[:contact_link_id])
    event = cl.event

    # start instrument
    instrument = Instrument.start(person, participant, instrument_survey, current_survey, event, Instrument.cati)

    # persist instrument and newly prepopulated response_set
    instrument.save!

    # add instrument to contact link
    link = instrument.link_to(person, cl.contact, event, current_staff_id)
    link.save!

    # redirect
    rs_access_code = instrument.response_sets.where(:survey_id => current_survey.id).last.try(:access_code)
    redirect_to(surveyor.edit_my_survey_path(:survey_code => params[:survey_access_code], :response_set_code => rs_access_code))
  end

  # GET /people/1/start_consent
  def start_consent
    # get information from params
    person = Person.find(params[:id])
    participant = Participant.find(params[:participant_id])
    survey = Survey.most_recent_for_access_code(params[:survey_access_code])

    # determine contact
    cl = person.contact_links.includes(:event, :contact).find(params[:contact_link_id])
    contact = cl.contact

    # start consent
    consent = ParticipantConsent.start!(person, participant, survey, contact, cl)

    # redirect
    rs_access_code = consent.response_set.try(:access_code)
    redirect_to(surveyor.edit_my_survey_path(:survey_code => params[:survey_access_code], :response_set_code => rs_access_code))
  end

  # GET /people/1/start_non_interview_report
  def start_non_interview_report
    # get information from params
    person = Person.find(params[:id])
    participant = Participant.find(params[:participant_id])
    survey = Survey.most_recent_for_access_code(params[:survey_access_code])

    # determine contact
    cl = person.contact_links.includes(:event, :contact).find(params[:contact_link_id])
    contact = cl.contact

    # start nir
    nir = NonInterviewReport.start!(person, participant, survey, contact)

    # redirect
    rs_access_code = nir.response_set.try(:access_code)
    redirect_to(surveyor.edit_my_survey_path(:survey_code => params[:survey_access_code], :response_set_code => rs_access_code))
  end

  def responses_for
    @person = Person.find(params[:id])
    if request.put?
      @responses = []
      if params[:data_export_identifier]
        @responses = @person.responses_for(params[:data_export_identifier])
      end
    end
  end

  ##
  # Show changes
  def versions
    @person = Person.find(params[:id])
    if params[:export]
      send_data(@person.export_versions, :filename => "#{@person.public_id}.csv")
    end
  end

  def set_person_attribute_defaults(person, child = false)
    if person.p_info_date.blank?
      dt = person.new_record? ? Date.today : person.created_at.to_date
      person.p_info_date = dt
    end
    if person.p_info_source_code.blank? && !child
      person.p_info_source_code = Person.person_self_code
    end
    person.p_info_update      = Date.today
  end
  private :set_person_attribute_defaults

  ##
  # Create relationship to participant if paramaters include
  # participant_id and relationship code
  def create_relationship_to_participant
    relationship_code = params[:relationship_code]
    if @participant && relationship_code
      ParticipantPersonLink.create(:participant => @participant, :person => @person,
                                   :relationship_code => params[:relationship_code])
    end
  end
  private :create_relationship_to_participant

  def set_participant
    if params[:participant_id]
      @participant = Participant.find(params[:participant_id])
    end
  end
  private :set_participant

end
