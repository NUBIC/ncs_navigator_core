# -*- coding: utf-8 -*-
class SpecimenReceiptsController < ApplicationController

  def new
    @specimen = Specimen.where(:specimen_id => params[:specimen_id]).first
    @specimen_storage_container = SpecimenStorageContainer.new
    @specimen_receipt = @specimen_storage_container.build_specimen_receipt(:specimen => @specimen)
  end

  def create
    params[:specimen_storage_container][:specimen_receipt_attributes].merge!(:psu_code => @psu_code, :staff_id => current_staff_id, :specimen_processing_shipping_center_id => SpecimenProcessingShippingCenter.last.id)
    @specimen_storage_container = SpecimenStorageContainer.new(params[:specimen_storage_container])
    respond_to do |format|
      if @specimen_storage_container.save
        @specimen = @specimen_storage_container.specimen_receipt.specimen
        format.json { render :json => @specimen_storage_container, :include => {:specimen_receipt, {:include => :specimen}}}
      else
        format.json { render :json => @specimen_storage_container.errors, :status => :unprocessable_entity }
      end
    end
  end

  def show
    @specimen_storage_container = SpecimenStorageContainer.find(params[:id])
  end

  def edit
    @specimen_storage_container = SpecimenStorageContainer.find(params[:id])
  end

  def update
    @specimen_storage_container = SpecimenStorageContainer.find(params[:id])
    respond_to do |format|
      if @specimen_storage_container.update_attributes(params[:specimen_storage_container])
        @specimen = @specimen_storage_container.specimen_receipt.specimen
        format.json { render :json => @specimen_storage_container, :include => {:specimen_receipt, {:include => :specimen}}}
      else
        format.json { render :json => @specimen_storage_container.errors, :status => :unprocessable_entity }
      end
    end
  end
end