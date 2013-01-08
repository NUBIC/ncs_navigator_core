class PpgDetailsController < ApplicationController

  def edit
    @participant = Participant.find(params[:participant_id])
    @person = @participant.person
    @ppg_detail = PpgDetail.find(params[:id])
  end

  def update
    @participant = Participant.find(params[:participant_id])
    @person = @participant.person
    @ppg_detail = PpgDetail.find(params[:id])

    if @ppg_detail.update_attributes(params[:ppg_detail])
      flash[:notice] = 'Original Due Date was successfully updated.'
      redirect_to(participant_path(@participant.id))
    else
      render :action => "edit"
    end
  end

end
