# -*- coding: utf-8 -*-
class SpecimenReceiptsController < ApplicationController
  before_filter do
    @in_edit_mode = params[:in_edit_mode] == 'true'
  end

  def new
    @specimen = Specimen.where(:specimen_id => params[:specimen_id]).first
    @specimen_storage_container = SpecimenStorageContainer.new
    @specimen_receipt = @specimen_storage_container.specimen_receipts.build(:specimen => @specimen)
  end

  def create
    errors = false
    @specimen_storage_container = SpecimenStorageContainer.new
    if params[:specimen_storage_container].blank?
      errors = true
    elsif params[:specimen_storage_container][:specimen_receipts_attributes].blank?
      errors = true
    else
      params[:specimen_storage_container][:specimen_receipts_attributes].each do |key, params|
        params.merge!(:psu_code => @psu_code, :staff_id => current_staff_id, :specimen_processing_shipping_center_id => SpecimenProcessingShippingCenter.last.id)
      end
    
      @specimen_storage_container = SpecimenStorageContainer.where(:storage_container_id => params[:specimen_storage_container][:storage_container_id]).first
      if (@specimen_storage_container.blank?)
        @specimen_storage_container = SpecimenStorageContainer.new(:storage_container_id => params[:specimen_storage_container][:storage_container_id])
      end

      @specimen_receipt = @specimen_storage_container.specimen_receipts.build(params[:specimen_storage_container][:specimen_receipts_attributes]["0"])
    end
    respond_to do |format|
      if !errors && @specimen_storage_container.save
        @specimen = @specimen_receipt.specimen
        format.json { render :json => @specimen_receipt, :include => [:specimen, :specimen_storage_container]}
      else
        format.json { render :json => @specimen_storage_container.errors, :status => :unprocessable_entity }
      end
    end
  end

  def show
    @specimen_receipt = SpecimenReceipt.find(params[:id])
  end

  def edit
    @specimen_receipt = SpecimenReceipt.find(params[:id])
    @specimen_storage_container = SpecimenStorageContainer.find(@specimen_receipt.specimen_storage_container_id)
  end

  def update
    @specimen_receipt = SpecimenReceipt.find(params[:id])
    @params = params[:specimen_receipt]
    respond_to do |format|
      if @specimen_receipt.update_attributes(@params)
        @specimen = @specimen_receipt.specimen
        format.json { render :json => @specimen_receipt, :include => :specimen }
      else
        format.json { render :json => @specimen_receipt.errors, :status => :unprocessable_entity  }
      end
    end
  end
end