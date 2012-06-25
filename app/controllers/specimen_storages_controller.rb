class SpecimenStoragesController < ApplicationController

  def new
    @specimen_storage = SpecimenStorage.new(:storage_container_id => params[:container_id])
  end
  
  def create
    @params = params[:specimen_storage]
    @params[:psu_code] = @psu_code
    # @params[:staff_id] = "Jane Dow"
    @params[:specimen_processing_shipping_center_id] = SpecimenProcessingShippingCenter.last.id
    @params = extract_date_time(@params)
    @specimen_storage = SpecimenStorage.new(@params)
    respond_to do |format|
     if @specimen_storage.save
         format.html { redirect_to(store_specimen_sample_processes_path(@specimen_storage), :notice => 'Specimen Storage was successfully created.') }
         format.json { render :json => @specimen_storage }
       else
         format.html { render :action => "new", :locals => { :errors => @specimen_storage.errors } }
         format.json { render :json => @specimen_storage.errors, :status => :unprocessable_entity  }
       end
    end    
  end
  
  def extract_date_time(params)
    @datetime_hash = @params[:placed_in_storage_datetime]
    if @datetime_hash.is_a?(Hash) 
      @datetime = @datetime_hash.values.first
      params[:placed_in_storage_datetime] = @datetime
    end
  
    @starttime_hash = @params[:temp_event_starttime] 
    if @starttime_hash.is_a?(Hash) 
      @starttime = @starttime_hash.values.first
      params[:temp_event_starttime] = @starttime
    end
    
    @endtime_hash = @params[:temp_event_endtime]
    if @endtime_hash.is_a?(Hash)  
      @endtime = @endtime_hash.values.first
      params[:temp_event_endtime] = @endtime
    end
    return params
  end
  
  def show
    @specimen_storage = SpecimenStorage.find(params[:id])
  end
  
  def edit
    @specimen_storage = SpecimenStorage.find(params[:id])
  end
  
  def update
    @specimen_storage = SpecimenStorage.find(params[:id])
    @params = params[:specimen_storage]
    @params = extract_date_time(@params)    
    respond_to do |format|
      if @specimen_storage.update_attributes(@params)
        format.json { render :json => @specimen_storage }
      else
        format.json { render :json => @specimen_storage.errors, :status => :unprocessable_entity  }
      end
    end
  end
  
end