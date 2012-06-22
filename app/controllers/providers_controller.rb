# -*- coding: utf-8 -*-

class ProvidersController < ApplicationController

  def index
    params[:page] ||= 1

    @q = Provider.search(params[:q])
    result = @q.result(:distinct => true)
    @providers = result.paginate(:page => params[:page], :per_page => 20)

    respond_to do |format|
      format.html
      format.json { render :json => result.all }
    end
  end

  def show
    @provider = Provider.find(params[:id])
  end

  def new
    @provider = Provider.new(:psu_code => @psu_code, :provider_info_date => Date.today)
    @provider.provider_info_update = Date.today

    respond_to do |format|
      format.html
      format.json { render :json => @provider }
    end
  end

  def edit
    @provider = Provider.find(params[:id])
    @provider.provider_info_update = Date.today

    respond_to do |format|
      format.html
      format.json { render :json => @provider }
    end
  end

  def create
    @provider = Provider.new(params[:provider])

    respond_to do |format|
      if @provider.save
        flash[:notice] = 'Provider was successfully created.'
        format.html { redirect_to(edit_provider_path(@provider)) }
        format.json  { render :json => @provider }
      else
        format.html { render :action => "new" }
        format.json  { render :json => @provider.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @provider = Provider.find(params[:id])

    respond_to do |format|
      if @provider.update_attributes(params[:provider])
        flash[:notice] = 'Provider was successfully updated.'
        format.html { redirect_to(edit_provider_path(@provider)) }
        format.json  { render :json => @provider }
      else
        format.html { render :action => "edit" }
        format.json  { render :json => @provider.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit_contact_information
    @provider = Provider.find(params[:id])
    @event = Event.find(params[:event_id]) if params[:event_id]
    if @provider.address.blank?
      @provider.build_address(:psu_code => @psu_code)
    end
    if @provider.telephone.blank?
      @provider.telephones.build(:psu_code => @psu_code, :phone_type => Telephone.work_phone_type)
    end
    if @provider.fax.blank?
      @provider.telephones.build(:psu_code => @psu_code, :phone_type => Telephone.fax_phone_type)
    end
    if @provider.primary_contact.blank?
      staff = @provider.staff.build(:psu_code => @psu_code)
      staff.emails.build(:psu_code => @psu_code)
      staff.telephones.build(:psu_code => @psu_code, :phone_type => Telephone.work_phone_type)
    end

    respond_to do |format|
      format.html
      format.json { render :json => @provider }
    end
  end

  def update_contact_information
    @provider = Provider.find(params[:id])
    @event = Event.find(params[:event_id]) if params[:event_id]
    respond_to do |format|
      if @provider.update_attributes(params[:provider])

        if params[:save_primary_contact] && !@provider.staff.blank?
          pc = @provider.personnel_provider_links.where(:person_id => @provider.staff.first.id).first
          pc.update_attribute(:primary_contact, true) unless pc.blank?
        end

        flash[:notice] = 'Provider contact information was successfully updated.'
        path = @event.blank? ? edit_contact_information_provider_path(@provider) : staff_list_provider_path(@provider, :event_id => @event.id)

        format.html { redirect_to(path) }
        format.json  { render :json => @provider }
      else
        format.html { render :action => "edit" }
        format.json  { render :json => @provider.errors, :status => :unprocessable_entity }
      end
    end
  end

  def staff_list
    @provider = Provider.find(params[:id])
    @event = Event.find(params[:event_id]) if params[:event_id]
  end

  def contact_log
    @provider = Provider.find(params[:id])
  end

  def new_staff
    @provider = Provider.find(params[:id])
    @event = Event.find(params[:event_id]) if params[:event_id]
    @staff = Person.new
    @telephone = Telephone.new(:person => @staff)
    @email = Email.new(:person => @staff)
    @link = PersonnelProviderLink.new(:person => @staff, :provider => @provider)
  end

  def create_staff
    @provider = Provider.find(params[:id])
    @staff = Person.new(params[:person])

    @telephone = process_staff_phone
    @email = process_staff_email

    respond_to do |format|
      if @staff.save

        @telephone.save if @telephone
        @email.save if @email

        process_personnel_provider_link

        flash[:notice] = 'Provider Staff was successfully created.'
        format.html { redirect_to(post_staff_redirect_path) }
      else
        format.html { render :action => "new_staff" }
      end
    end
  end

  def edit_staff
    @provider = Provider.find(params[:id])
    if params[:person_id]
      @event = Event.find(params[:event_id]) if params[:event_id]
      @staff = Person.find(params[:person_id])
      @link = PersonnelProviderLink.find_by_person_id_and_provider_id(@staff.id, @provider.id)
      @telephone = @staff.telephones.first
      @email = @staff.emails.first
    else
      flash[:warning] = 'Person identifier required.'
      redirect_to staff_list_provider_path(@provider)
    end
  end

  def update_staff
    @provider = Provider.find(params[:id])
    @staff = Person.find(params[:person_id])
    @event = Event.find(params[:event_id]) if params[:event_id]

    @telephone = process_staff_phone
    @email = process_staff_email

    respond_to do |format|
      if @staff.update_attributes(params[:person])

        @telephone.save if @telephone && @telephone.changed?
        @email.save if @email && @email.changed?

        process_personnel_provider_link

        flash[:notice] = 'Provider Staff was successfully created.'
        format.html { redirect_to(post_staff_redirect_path) }
      else
        format.html { render :action => "new_staff" }
      end
    end

  end

  def post_staff_redirect_path
    if params[:event_id]
      staff_list_provider_path(@provider, :event_id => params[:event_id])
    else
      staff_list_provider_path(@provider)
    end
  end

  def process_staff_phone
    unless params[:telephone].blank?
      if params[:telephone_id]
        @telephone = Telephone.find(params[:telephone_id])
        @telephone.phone_nbr = params[:telephone][:phone_nbr]
      else
        @telephone = Telephone.new(:person => @staff, :phone_nbr => params[:telephone][:phone_nbr])
      end
    end
    @telephone
  end
  private :process_staff_phone

  def process_staff_email
    unless params[:email].blank?
      if params[:email_id]
        @email = Email.find(params[:email_id])
        @email.email = params[:email][:email]
      else
        @email = Email.new(:person => @staff, :email => params[:email][:email])
      end
    end
    @email
  end
  private :process_staff_email

  def process_personnel_provider_link
    @link = PersonnelProviderLink.find_or_create_by_person_id_and_provider_id(@staff.id, @provider.id)
    if params[:primary_contact].to_s == "1"
      @link.primary_contact = true
      @link.save!
    end
  end

  def post_recruitment_contact
    @provider = Provider.find(params[:id])
  end

  def recruited
    @provider = Provider.find(params[:id])
    @provider.provider_logistics.build if @provider.provider_logistics.blank?
  end

  def process_recruited
    @provider = Provider.find(params[:id])

    respond_to do |format|
      if @provider.update_attributes(params[:provider])

        mark_pbs_list_as_having_recruited_provider(@provider.pbs_list)

        flash[:notice] = "Provider #{@provider} has been successfully recruited."
        format.html { redirect_to(pbs_lists_path) }
        format.json  { render :json => @provider }
      else
        format.html { render :action => "recruited" }
        format.json  { render :json => @provider.errors, :status => :unprocessable_entity }
      end
    end
  end

  def mark_pbs_list_as_having_recruited_provider(pbs_list)
    attrs = {
      :pr_cooperation_date => Date.today,
      :pr_recruitment_end_date => Date.today,
      :pr_recruitment_status_code => 4
    }
    pbs_list.update_attributes(attrs) unless pbs_list.recruitment_ended?
  end
  private :mark_pbs_list_as_having_recruited_provider


end
