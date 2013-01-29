# -*- coding: utf-8 -*-


class ParticipantConsentsController < ApplicationController

  # TODO: set the person who consented or who withdrew consent
  #  person_who_consented_id         :integer
  #  person_wthdrw_consent_id        :integer

  # GET /participant_consents/new
  # GET /participant_consents/new.json
  def new
    @consent_type_code = params[:consent_type_code]
    @participant  = Participant.find(params[:participant_id])
    @contact_link = ContactLink.find(params[:contact_link_id])
    @contact = @contact_link.contact
    @participant_consent = ParticipantConsent.new(:participant => @participant,
                                                  :contact => @contact,
                                                  :consent_form_type_code => @consent_type_code.to_i,
                                                  :consent_date => Date.today)

    build_participant_consent_samples

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @participant_consent }
    end
  end

  # GET /participant_consents/1/edit
  def edit
    @participant_consent = ParticipantConsent.find(params[:id])
    @contact_link = ContactLink.find(params[:contact_link_id]) unless params[:contact_link_id].blank?
    @participant = @participant_consent.participant
    @contact = @participant_consent.contact

    if @participant_consent.phase_two? && @participant_consent.participant_consent_samples.blank?
      build_participant_consent_samples
    end
  end

  # POST /participant_consents
  # POST /participant_consents.json
  def create
    @contact_link = ContactLink.find(params[:contact_link_id])
    @participant_consent = ParticipantConsent.new(params[:participant_consent])

    @consent_type_code = @participant_consent.consent_type_code
    @participant  = @participant_consent.participant
    @contact = @contact_link.contact

    respond_to do |format|
      if @participant_consent.save

        post_create_actions(@participant)

        format.html { redirect_to decision_page_contact_link_path(@contact_link), :notice => 'Participant consent was successfully created.' }
        format.json { render :json => @participant_consent, :status => :created, :location => @participant_consent }
      else
        format.html { render :action => "new" }
        format.json { render :json => @participant_consent.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /participant_consents/1
  # PUT /participant_consents/1.json
  def update
    @participant_consent = ParticipantConsent.find(params[:id])
    @contact_link = ContactLink.find(params[:contact_link_id]) unless params[:contact_link_id].blank?
    @participant = @participant_consent.participant
    @contact = @participant_consent.contact

    respond_to do |format|
      if @participant_consent.update_attributes(params[:participant_consent])

        update_enrollment_status

        format.html { redirect_to redirect_action, :notice => 'Participant consent was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @participant_consent.errors, :status => :unprocessable_entity }
      end
    end
  end

  # GET /participant_consents/new_child
  def new_child
    @participant = Participant.new
    @child_guardian = Participant.find(params[:participant_id])
    @contact_link = ContactLink.find(params[:contact_link_id])
    @contact = @contact_link.contact
    @participant_consent = ParticipantConsent.new(:contact => @contact,
                                                  :psu => @child_guardian.psu,
                                                  :consent_form_type_code => 6, # Consent for the child’s participation
                                                  :consent_date => Date.today)

    build_participant_consent_samples

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # POST /participant_consents/create_child
  def create_child
    @child_guardian = Participant.find(params[:participant_id])
    child_participant = @child_guardian.create_child_person_and_participant!(params[:person])

    @contact_link = ContactLink.find(params[:contact_link_id])
    @participant_consent = ParticipantConsent.new(params[:participant_consent])
    @participant_consent.participant = child_participant
    @participant_consent.person_who_consented = @child_guardian.person
    @participant_consent.contact = @contact_link.contact

    respond_to do |format|
      if @participant_consent.save

        post_create_actions(@child_guardian)

        format.html { redirect_to decision_page_contact_link_path(@contact_link), :notice => 'Participant consent was successfully created.' }
        format.json { render :json => @participant_consent, :status => :created, :location => @participant_consent }
      else
        format.html { render :action => "new" }
        format.json { render :json => @participant_consent.errors, :status => :unprocessable_entity }
      end
    end
  end

  private

    def build_participant_consent_samples
      ParticipantConsentSample::SAMPLE_CONSENT_TYPE_CODES.each do |code|
        @participant_consent.participant_consent_samples.build(:sample_consent_type_code => code, :participant => @participant)
      end
    end

    ##
    # After creation of a ParticipantConsent record
    # we need to
    # 1. Mark the activity as occurred in PSC
    # 2. Update the enrollment status of the Participant
    # 3. Create an Informed Consent event for the given Participant
    # @param[Participant]
    def post_create_actions(participant)
      mark_activity_occurred
      update_enrollment_status
      create_informed_consent_event(participant, @contact_link)
    end

    ##
    # Updates activities associated with this event
    # that are known to be consent activities
    # in PSC as 'occurred'
    def mark_activity_occurred
	    psc.activities_for_event(@contact_link.event).each do |a|
        if a.consent_activity?
	        psc.update_activity_state(a.activity_id,
                                    @contact_link.person.participant,
                                    Psc::ScheduledActivity::OCCURRED)
        end
      end
    end

    ##
    # Either enroll or unenroll the participant based on the
    # recently updated participant consent
    def update_enrollment_status
      participant = Participant.find(@participant_consent.participant_id)
      if @participant_consent.consented?
        participant.enroll! unless participant.enrolled?
      else
        participant.unenroll!(psc, "Consent withdrawn") unless participant.unenrolled?
      end
    end

    ##
    # Creates an Informed Consent Event for the given participant and contact_link
    # @param[Participant]
    # @param[ContactLink]
    def create_informed_consent_event(participant, contact_link)
      contact = contact_link.contact
      if should_create_informed_consent_record?(participant, contact)
        ActiveRecord::Base.transaction do
          comment = "Informed Consent Event record created from ParticipantConsent record"
          event = Event.create(:participant => participant,
                               :event_type_code => Event.informed_consent_code,
                               :event_breakoff_code => NcsCode::NO,
                               :event_comment => comment,
                               :event_start_date => determine_informed_consent_event_date(contact_link),
                               :event_repeat_key => 0)
          ContactLink.create(:event => event, :contact => contact,
                             :person => contact_link.person, :staff_id => contact_link.staff_id)
        end
      end
    end

    ##
    # Determine a default start date for this event
    # First check associated event, then check associated contact, then use today
    # @param[ContactLink]
    # @return[Date]
    def determine_informed_consent_event_date(contact_link)
      dt = Date.today
      if !contact_link.contact.try(:contact_date).blank?
        dt = contact_link.contact.try(:contact_date)
      elsif !contact_link.event.try(:event_start_date).blank?
        dt = contact_link.event.try(:event_start_date)
      end
      dt
    end

    ##
    # Return true if there are no Informed Consent Events associated with
    # the given Participant.
    #
    # If there are Informed Consent Events associated with the participant
    # return true if none are associated with the given Contact.
    #
    # Create one Informed Consent for the Participant per Contact
    #
    # @param[Participant]
    # @param[Contact]
    # @return[Boolean]
    def should_create_informed_consent_record?(participant, contact)
      rel = Event.where(:participant_id => participant.id, :event_type_code => Event.informed_consent_code)
      rel.count == 0 || !rel.joins(:contacts).exists?('contacts.id' => contact.id)
    end
    private :should_create_informed_consent_record?

    def redirect_action
      if params[:contact_link_id]
        @contact_link = ContactLink.find(params[:contact_link_id])
        decision_page_contact_link_path(@contact_link)
      else
        person_path(@participant_consent.participant.person)
      end

    end

end
