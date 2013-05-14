# -*- coding: utf-8 -*-


class ProvidersController < ApplicationController

  def index
    params[:page] ||= 1

    params[:q] ||= Hash.new
    params[:q]['s'] ||= "name_practice asc"

    @q, @providers = ransack_paginate(Provider)

    respond_to do |format|
      format.html
      format.json { render :json => @q.result.all }
    end
  end

  def patients_paginate(people, page_type)
    page_num = params[page_type] || 1
    page = WillPaginate::Collection.create(page_num, 10) do |pager|
      pager.replace(people[pager.offset, pager.per_page])
      pager.total_entries = people.length
    end
    page
  end
  private :patients_paginate

  def show
    @provider = Provider.find(params[:id])
    non_batch = Person.associated_with_provider_by_provider_id(@provider.id)
    @patients = patients_paginate(non_batch, :patients_page)
    @batch = patients_paginate(IneligibleBatch.
                         where(:provider_id => @provider.id).
                         order("date_first_visit_date DESC, people_count"),
                                                          :inpatients_page)
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
      @provider.telephones.build(:psu_code => @psu_code,
                                 :phone_type => Telephone.work_phone_type,
                                 :phone_rank_code => 1)
    end
    if @provider.fax.blank?
      @provider.telephones.build(:psu_code => @psu_code,
                                 :phone_type => Telephone.fax_phone_type,
                                 :phone_rank_code => 1)
    end
    if @provider.primary_contact.blank?
      staff = @provider.staff.build(:psu_code => @psu_code)
      staff.emails.build(:psu_code => @psu_code, :email_rank_code => 1)
      staff.telephones.build(:psu_code => @psu_code,
                             :phone_type => Telephone.work_phone_type,
                             :phone_rank_code => 1)
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
        format.json { render :json => { :id => @staff.id, :provider_id => @provider.id, :errors => [] }, :status => :ok }
      else

        @telephone = Telephone.new(:person => @staff) if @telephone.nil?
        @email = Email.new(:person => @staff) if @email.nil?

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

      @telephone = Telephone.new(:person => @staff) if @telephone.blank?
      @email = Email.new(:person => @staff) if @email.blank?
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
        format.json { render :json => { :id => @staff.id, :provider_id => @provider.id, :errors => [] }, :status => :ok }
      else

        @telephone = Telephone.new(:person => @staff) if @telephone.nil?
        @email = Email.new(:person => @staff) if @email.nil?

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
    if !params[:telephone_number].blank?
      if params[:telephone_id]
        @telephone = Telephone.find(params[:telephone_id])
        @telephone.phone_nbr = params[:telephone_number]
        @telephone.phone_rank_code = 1 if @telephone.phone_rank_code.to_i <= 0
        @telephone.phone_type_code = Telephone.work_phone_type.to_i if @telephone.phone_type_code.to_i <= 0
      else
        @telephone = Telephone.new(:person => @staff, :phone_nbr => params[:telephone_number],
                                   :phone_rank_code => 1, :phone_type_code => Telephone.work_phone_type.to_i)
      end
    end
    @telephone
  end
  private :process_staff_phone

  def process_staff_email
    if !params[:email].blank?
      if params[:email_id]
        @email = Email.find(params[:email_id])
        @email.email = params[:email]
        @email.email_rank_code = 1 if @email.email_rank_code.to_i <= 0
      else
        @email = Email.new(:person => @staff, :email => params[:email], :email_rank_code => 1)
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
    @contact  = Contact.find(params[:contact_id])
  end

  def recruited
    @provider = Provider.find(params[:id])
    @contact  = Contact.find(params[:contact_id]) if params[:contact_id]
    @provider.provider_logistics.build if @provider.provider_logistics.blank?
  end

  def process_recruited
    @provider = Provider.find(params[:id])
    @contact  = Contact.find(params[:contact_id]) if params[:contact_id]

    respond_to do |format|
      if @provider.update_attributes(params[:provider])
        @provider.pbs_list.update_recruitment_status!
        @provider.pbs_list.update_recruitment_dates!

        flash[:notice] = "Provider #{@provider} has been successfully recruited."
        format.html { redirect_to(pbs_list_path(@provider.pbs_list)) }
        format.json  { render :json => @provider }
      else
        format.html { render :action => "recruited" }
        format.json  { render :json => @provider.errors, :status => :unprocessable_entity }
      end
    end
  end

  def refused
    @provider = Provider.find(params[:id])
    @pbs_list = @provider.pbs_list

    if @pbs_list && @pbs_list.has_substitute_provider?
      flash[:warning] = "PBS List record already has #{@pbs_list.substitute_provider} marked as substitute."
      redirect_to pbs_lists_path
    end
  end

  def process_refused
    @provider = Provider.find(params[:id])
    @pbs_list = @provider.pbs_list

    mark_pbs_list_refused(@pbs_list) if @pbs_list

    flash[:notice] = "Provider marked as not willing to participate."
    redirect_to(pbs_lists_path)
  end

  def mark_pbs_list_refused(pbs_list)
    @pbs_list.pr_recruitment_end_date = Date.today
    @pbs_list.pr_recruitment_status_code = 2
    if params[:substitute_provider_id]
      @pbs_list.substitute_provider = Provider.find(params[:substitute_provider_id])
    end
    @pbs_list.save!
  end
  private :mark_pbs_list_refused

  def batch_ineligible
    @provider = Provider.find(params[:id])
    @ineligible_batch = IneligibleBatch.new
    respond_to do |format|
      format.html
    end
  end
end
