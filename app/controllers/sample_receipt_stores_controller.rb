# -*- coding: utf-8 -*-
class SampleReceiptStoresController < ApplicationController
  before_filter do
    @in_edit_mode = params[:in_edit_mode] == 'true'
  end

  def new
    @sample = Sample.where(:sample_id => params[:sample_id]).first
    @sample_receipt_store = @sample.build_sample_receipt_store()    
  end
  
  def create
    @params = params[:sample_receipt_store].merge!(:psu_code => @psu_code, :staff_id => current_staff_id, 
    :sample_receipt_shipping_center_id => SampleReceiptShippingCenter.last.id)
    @sample_receipt_store = SampleReceiptStore.new(@params)
    respond_to do |format|
      if @sample_receipt_store.save
        format.json { render :json =>@sample_receipt_store}
      else
        format.json { render :json => @sample_receipt_store.errors, :status => :unprocessable_entity }
      end
    end    
  end
  
  def show
    @sample_receipt_store = SampleReceiptStore.find(params[:id])
  end
  
  def edit
    @sample_receipt_store = SampleReceiptStore.find_by_sample_id(params[:id])
  end
  
  def update
    @sample_receipt_store = SampleReceiptStore.find(params[:id])
    respond_to do |format|
      if @sample_receipt_store.update_attributes(params[:sample_receipt_store])
        format.json { render :json => @sample_receipt_store }
      else
        format.json { render :json => @sample_receipt_store.errors, :status => :unprocessable_entity  }
      end
    end
  end
end