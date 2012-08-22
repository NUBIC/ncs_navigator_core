# -*- coding: utf-8 -*-
class SpecimenReceiptsController < ApplicationController

  def new
    @specimen = Specimen.where(:specimen_id => params[:specimen_id]).first
    @specimen_storage_container = SpecimenStorageContainer.new
    @specimen_receipt = @specimen_storage_container.specimen_receipts.build(:specimen => @specimen)
  end

  def create
    params[:specimen_storage_container][:specimen_receipts_attributes].each do |key, params|
      params.merge!(:psu_code => @psu_code, :staff_id => current_staff_id, :specimen_processing_shipping_center_id => SpecimenProcessingShippingCenter.last.id)
    end
    
    @specimen_storage_container = SpecimenStorageContainer.where(:storage_container_id => params[:specimen_storage_container][:storage_container_id]).first
    if (@specimen_storage_container.blank?)
      @specimen_storage_container = SpecimenStorageContainer.new(:storage_container_id => params[:specimen_storage_container][:storage_container_id])
    end

    @specimen_receipt = @specimen_storage_container.specimen_receipts.build(params[:specimen_storage_container][:specimen_receipts_attributes]["0"])
    respond_to do |format|
      if @specimen_storage_container.save
        puts @specimen_storage_container.inspect
        @specimen = @specimen_receipt.specimen
        # format.json { render :json => @specimen_storage_container, :include => {:specimen_receipts, {:include => :specimen}}}
        format.json { render :json => @specimen_receipt, :include => [:specimen, :specimen_storage_container]}
        # format.json { render :json => @specimen_receipt, :include => :specimen}
        
      else
        format.json { render :json => @specimen_storage_container.errors, :status => :unprocessable_entity }
      end
    end
  end

  def show
    @specimen_receipt = SpecimenReceipt.find(params[:id])
    # @specimen_storage_container = SpecimenStorageContainer.find(params[:id])
  end

  def edit
    @specimen_receipt = SpecimenReceipt.find(params[:id])
    @specimen_storage_container = SpecimenStorageContainer.find(@specimen_receipt.specimen_storage_container_id)
    # @specimen_storage_container = SpecimenStorageContainer.find(params[:id])
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
  
    
    # @specimen_storage_container = SpecimenStorageContainer.find(params[:id])
    # @spec_receipt_id = params[:specimen_storage_container][:specimen_receipts_attributes]["0"]["id"]
    # respond_to do |format|
    #   # if @specimen_storage_container.update_attributes(params[:specimen_storage_container])
    #   if @specimen_storage_container.update_attributes(params[:specimen_storage_container])
    #     @specimen_receipt = SpecimenReceipt.where(:id => @spec_receipt_id.to_i).first
    #     @specimen = @specimen_receipt.specimen
    #     # format.json { render :json => @specimen_storage_container, :include => {:specimen_receipts, {:include => :specimen}}}
    #     format.json { render :json => @specimen_receipt, :include => :specimen}
    #   else
    #     format.json { render :json => @specimen_storage_container.errors, :status => :unprocessable_entity }
    #   end
    # end
  end
  
  

  # def create
  #   params[:specimen_storage_container][:specimen_receipt_attributes].merge!(:psu_code => @psu_code, :staff_id => current_staff_id, :specimen_processing_shipping_center_id => SpecimenProcessingShippingCenter.last.id)
  #   
  #   @specimen_receipt = SpecimenReceipt.new(params[:specimen_storage_container][:specimen_receipt_attributes])
  #   
  #   
  #   @specimen_storage_container = SpecimenStorageContainer.where(:storage_container_id => params[:specimen_storage_container][:storage_container_id]).first
  #   if (@specimen_storage_container.blank?)
  #     @specimen_storage_container = SpecimenStorageContainer.new(:storage_container_id => params[:specimen_storage_container][:storage_container_id])
  #     @specimen_storage_container.save
  #   end
  #   @specimen_receipt.specimen_storage_container =  @specimen_storage_container
  # 
  #   respond_to do |format|
  #     if @specimen_receipt.save
  #       @specimen = @specimen_receipt.specimen
  #       format.json { render :json => @specimen_storage_container, :include => {:specimen_receipt, {:include => :specimen}}}
  #     else
  #       format.json { render :json => @specimen_receipt.errors, :status => :unprocessable_entity }
  #     end
  #   end
  # end  
end