class ParticipantConsentsController < ApplicationController

  # TODO: set the person who consented or who withdrew consent
  #  person_who_consented_id         :integer
  #  person_wthdrw_consent_id        :integer

  # GET /participant_consents/new
  # GET /participant_consents/new.json
  def new
    @participant  = Participant.find(params[:participant_id])
    @contact_link = ContactLink.find(params[:contact_link_id])
    @contact = @contact_link.contact
    @participant_consent = ParticipantConsent.new(:participant => @participant, :contact => @contact)

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @participant_consent }
    end
  end

  # GET /participant_consents/1/edit
  def edit
    @participant_consent = ParticipantConsent.find(params[:id])
    @contact_link = ContactLink.find(params[:contact_link_id])
    @participant = @participant_consent.participant
    @contact = @participant_consent.contact
  end

  # POST /participant_consents
  # POST /participant_consents.json
  def create
    @contact_link = ContactLink.find(params[:contact_link_id])
    @participant_consent = ParticipantConsent.new(params[:participant_consent])
    
    respond_to do |format|
      if @participant_consent.save
        format.html { redirect_to select_instrument_contact_link_path(@contact_link), :notice => 'Participant consent was successfully created.' }
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
    @contact_link = ContactLink.find(params[:contact_link_id])
    @participant_consent = ParticipantConsent.find(params[:id])

    respond_to do |format|
      if @participant_consent.update_attributes(params[:participant_consent])
        format.html { redirect_to select_instrument_contact_link_path(@contact_link), :notice => 'Participant consent was successfully created.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @participant_consent.errors, :status => :unprocessable_entity }
      end
    end
  end
end
