class PpgDetailsController < ApplicationController

  def edit
    params.each_pair { |k, v| p "key = #{k}, value = #{v}"}
    @participant = Participant.find(params[:id])
    @person = @participant.person
    @ppg_detail = @participant.ppg_details.first

    respond_to do |format|
      format.html
      format.json { render :json => @email }
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

  private

    def load_participant
      return unless params[:id]
      @participant =
        Participant.find_by_id(params[:id]) ||
        Participant.find_by_p_id(params[:id]) ||
        Person.includes(:participant_person_links => :participant).where(:person_id => params[:id]).first.try(:participant) ||
        raise(ActiveRecord::RecordNotFound, "Couldn't find Participant with id=#{params[:id]} or p_id=#{params[:id]} or self person_id=#{params[:id]}")
    end

end
