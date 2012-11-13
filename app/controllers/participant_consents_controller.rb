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

    respond_to do |format|
      if @participant_consent.save

        mark_activity_occurred
        update_enrollment_status

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
    if params[:contact_link_id]
      @contact_link = ContactLink.find(params[:contact_link_id])
      redirect_action = decision_page_contact_link_path(@contact_link)
    else
      redirect_action = person_path(@participant_consent.participant.person)
    end

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
    @participant_consent = ParticipantConsent.new(:participant => @participant,
                                                  :contact => @contact,
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

    respond_to do |format|
      if @participant_consent.save

        update_enrollment_status

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
    # Updates activities associated with this event
    # whose event is labeled 'informed_consent'
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

end
