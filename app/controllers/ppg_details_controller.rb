class PpgDetailsController < ApplicationController

  def edit
    @participant = Participant.find(params[:participant_id])
    @person = @participant.person
    @ppg_detail = PpgDetail.find(params[:id])

    respond_to do |format|
      format.html
    end
  end

  def update
    @participant = Participant.find(params[:participant_id])
    @person = @participant.person
    @ppg_detail = PpgDetail.find(params[:id])

    respond_to do |format|
      if @ppg_detail.update_attributes(params[:ppg_detail])
        flash[:notice] = 'Original Due Date was successfully updated.'
        format.html { redirect_to(participant_path(@participant.id)) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

end
