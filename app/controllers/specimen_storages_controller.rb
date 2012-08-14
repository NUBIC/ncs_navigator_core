# -*- coding: utf-8 -*-
class SpecimenStoragesController < ApplicationController
  def new
    @specimen_storage_container = SpecimenStorageContainer.where(:id => params[:container_id]).first
    # @specimen_receipt = @specimen_storage_container.build_specimen_receipt(:specimen => @specimen)
    
    # @specimen_storage = SpecimenStorage.new(:storage_container_id => params[:container_id])
    @specimen_storage = @specimen_storage_container.build_specimen_storage()
  end
  
  def create
    @params = params[:specimen_storage]
    @params[:psu_code] = @psu_code
    @params[:staff_id] = current_staff_id    
    @params[:specimen_processing_shipping_center_id] = SpecimenProcessingShippingCenter.last.id
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

  def show
    @specimen_storage = SpecimenStorage.find(params[:id])
  end
  
  def edit
    @specimen_storage = SpecimenStorage.find_by_storage_container_id(params[:id])
  end
  
  def update
    @specimen_storage = SpecimenStorage.find(params[:id])
    @params = params[:specimen_storage]
    respond_to do |format|
      if @specimen_storage.update_attributes(@params)
        format.json { render :json => @specimen_storage }
      else
        format.json { render :json => @specimen_storage.errors, :status => :unprocessable_entity  }
      end
    end
  end
end
