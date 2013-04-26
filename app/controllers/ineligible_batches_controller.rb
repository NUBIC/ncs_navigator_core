class IneligibleBatchesController < ApplicationController
  # GET /ineligible_batches/new
  def new
    @provider = Provider.find(params[:provider_id])
    @ineligible_batch = IneligibleBatch.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @ineligible_batch }
    end
  end

  # POST /ineligible_batches
  def create
    @provider = Provider.find(params[:provider_id])
    @ineligible_batch = IneligibleBatch.new(params[:ineligible_batch])
    @ineligible_batch.save!

    respond_to do |format|
        format.html { redirect_to @provider, notice: 'Ineligibility batch was successfully created.' }
        format.json { render json: @provider, status: :created, location: @ineligible_batch }
    end
  end

  # DELETE /ineligible_batches/1
  def destroy
    @provider = Provider.find(params[:provider_id])
    @ineligible_batch = IneligibleBatch.find(params[:id])
    @ineligible_batch.destroy

    respond_to do |format|
      format.html { redirect_to @provider }
      format.json { head :ok }
    end
  end
end
