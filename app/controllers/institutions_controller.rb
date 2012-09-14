class InstitutionsController < ApplicationController
  def index
    params[:page] ||= 1

    @q = Institution.search(params[:q])
    result = @q.result(:distinct => true)
    @addresses = result.paginate(:page => params[:page], :per_page => 20)

    respond_to do |format|
      format.html
      format.json { render :json => result.all }
    end
  end

  def show
    @institution = Institution.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render :json => @institution }
    end
  end

  def new
    @institution = Institution.new(:institute_info_date => Date.today,
                                   :institute_info_update => Date.today)
    if params[:provider_id]
      @provider = Provider.find(params[:provider_id])
      @institution.institute_name = @provider.to_s
      @institution.institute_type_code = 1 # Birthing Center
    end

    respond_to do |format|
      format.html
      format.json { render :json => @institution }
    end
  end

  def edit
    @institution = Institution.find(params[:id])
    @institution.institute_info_update = Date.today

    respond_to do |format|
      format.html
      format.json { render :json => @institution }
    end
  end

  def create
    @institution = Institution.new(params[:address])
    @provider = Provider.find(params[:provider_id]) if params[:provider_id]

    respond_to do |format|
      if @institution.save
        flash[:notice] = 'Institution was successfully created.'

        if @provider
          @provider.institution = @institution
          @provider.save!
          format.html { redirect_to(edit_provider_path(@provider)) }
          format.json  { render :json => @institution }
        else
          format.html { redirect_to(edit_institution_path(@institution)) }
          format.json  { render :json => @institution }
        end
      else
        format.html { render :action => "new" }
        format.json  { render :json => @institution.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @institution = Institution.find(params[:id])

    respond_to do |format|
      if @institution.update_attributes(params[:address])
        flash[:notice] = 'Institution was successfully updated.'
        format.html { redirect_to(edit_institution_path(@institution)) }
        format.json  { render :json => @institution }
      else
        format.html { render :action => "edit" }
        format.json  { render :json => @institution.errors, :status => :unprocessable_entity }
      end
    end
  end


end
