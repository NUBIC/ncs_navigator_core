# -*- coding: utf-8 -*-
class SpecimenReceiptsController < ApplicationController

  def new
    @specimen_receipt = SpecimenReceipt.new(:specimen_id => params[:specimen_id])
  end

  def create
    @params = params[:specimen_receipt]
    @params[:psu_code] = @psu_code
    @params[:staff_id] = current_staff_id
    @params[:specimen_processing_shipping_center_id] = SpecimenProcessingShippingCenter.last.id
    @specimen_receipt = SpecimenReceipt.new(@params)
    respond_to do |format|
     if @specimen_receipt.save
        format.html { redirect_to(receive_specimen_sample_processes_path(@specimen_receipt), :notice => 'Specimen Form was successfully created.') }
        format.json { render :json => @specimen_receipt}
      else
        format.html { render :action => "new"}
        format.json { render :json => @specimen_receipt.errors, :status => :unprocessable_entity }
      end
    end
  end

  def show
    @specimen_receipt = SpecimenReceipt.find(params[:id])
  end

  def edit
    @specimen_receipt = SpecimenReceipt.find_by_specimen_id(params[:id])
  end

  def update
    @specimen_receipt = SpecimenReceipt.find(params[:id])
    respond_to do |format|
      if @specimen_receipt.update_attributes(params[:specimen_receipt])
        format.json { render :json => @specimen_receipt}
      else
        format.json { render :json => @specimen_receipt.errors, :status => :unprocessable_entity }
      end
    end
  end
end