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
    @participant_consent = ParticipantConsent.new(:participant => @participant, :contact => @contact,
      :consent_type_code => @consent_type_code.to_i, :consent_form_type_code => @consent_type_code.to_i,
      :consent_date => Date.today)

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @participant_consent }
    end
  end

  # GET /participant_consents/1/edit
  def edit
    @consent_type_code = params[:consent_type_code]
    @participant_consent = ParticipantConsent.find(params[:id])
    @contact_link = ContactLink.find(params[:contact_link_id]) unless params[:contact_link_id].blank?
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
    @participant_consent = ParticipantConsent.find(params[:id])
    if params[:contact_link_id]
      @contact_link = ContactLink.find(params[:contact_link_id])
      redirect_action = select_instrument_contact_link_path(@contact_link)
    else
      redirect_action = person_path(@participant_consent.participant.person)
    end

    respond_to do |format|
      if @participant_consent.update_attributes(params[:participant_consent])
        format.html { redirect_to redirect_action, :notice => 'Participant consent was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @participant_consent.errors, :status => :unprocessable_entity }
      end
    end
  end
end
