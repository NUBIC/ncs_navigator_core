class SampleReceiptStoresController < ApplicationController

   def new
    @sample_receipt_store = SampleReceiptStore.new(:sample_id => params[:sample_id])
  end
  
  def create
    @params = params[:sample_receipt_store]
    @params[:psu_code] = @psu_code
    @params[:staff_id] = current_staff_id
    @params[:sample_receipt_shipping_center_id] = SampleReceiptShippingCenter.last.id
    @params[:placed_in_storage_datetime] = DateTime.now
    @sample_receipt_store = SampleReceiptStore.new(@params)
    respond_to do |format|
      if @sample_receipt_store.save
        format.html { redirect_to(receive_specimen_sample_processes_path(@sample_receipt_store), :notice => 'Specimen Form was successfully created.') }
        format.json { render :json =>@sample_receipt_store}
      else
        format.html { render :action => "new"}
        format.json { render :json => @sample_receipt_store.errors, :status => :unprocessable_entity }
      end
    end    
  end
  
  def show
    @receive = params[:receive]
    @sample_receipt_store = SampleReceiptStore.find(params[:id])
  end
  
  def edit
    @receive = params[:receive]
    @sample_receipt_store = SampleReceiptStore.find(params[:id])
  end
  
  def extract_date_time(params)
    @datetime = @params[:placed_in_storage_datetime]
    if @datetime.is_a?(Hash)
      @datetime = @datetime.values.first
    end
    params[:placed_in_storage_datetime] = @datetime
    return params
  end
  
  def receive_edit
    @sample_receipt_store = SampleReceiptStore.find(params[:id])
  end
  
  def update
    @sample_receipt_store = SampleReceiptStore.find(params[:id])
    @params = params[:sample_receipt_store]
    @params = extract_date_time(@params)
    if (@params[:placed_in_storage_datetime].blank?)
      @params[:placed_in_storage_datetime] = DateTime.now
    end
    respond_to do |format|
      if @sample_receipt_store.update_attributes(@params)
        format.json { render :json => @sample_receipt_store }
      else
        format.json { render :json => @sample_receipt_store.errors, :status => :unprocessable_entity  }
      end
    end
  end
end