# -*- coding: utf-8 -*-
class SpecimenStoragesController < ApplicationController
  def new
    @specimen_storage_container = SpecimenStorageContainer.where(:id => params[:container_id]).first
    @specimen_storage = @specimen_storage_container.build_specimen_storage()
  end
  
  def create
    @params = params[:specimen_storage].merge!(:psu_code => @psu_code, :staff_id => current_staff_id, :specimen_processing_shipping_center_id => SpecimenProcessingShippingCenter.last.id)
    @specimen_storage = SpecimenStorage.new(@params)
    respond_to do |format|
     if @specimen_storage.save
       format.json { render :json => @specimen_storage }
     else
       format.json { render :json => @specimen_storage.errors, :status => :unprocessable_entity  }
     end
    end    
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
    respond_to do |format|
      if @specimen_storage.update_attributes(@params)
        format.json { render :json => @specimen_storage }
      else
        format.json { render :json => @specimen_storage.errors, :status => :unprocessable_entity  }
      end
    end
  end
end
