class PpgDetailsController < ApplicationController

  def edit
    @participant = Participant.find(params[:id])
    @person = @participant.person
    @ppg_detail = @participant.ppg_details.first

    respond_to do |format|
      format.html
      format.json { render :json => @ppg_detail }
    end
  end

  def update
    @participant = Participant.find(params[:id])
    @person = @participant.person
    @ppg_details = @participant.ppg_details.first

    respond_to do |format|
      if @ppg_details.update_attributes(params[:orig_due_date])
        flash[:notice] = 'Original Due Date was successfully updated.'
        format.html { redirect_to(participant_path) }
        format.json  { render :json => @ppg_details }
      else
        format.html { render :action => "edit" }
        format.json  { render :json => @ppg_details.errors, :status => :unprocessable_entity }
      end
    end
  end

end
