class FieldworkController < ApplicationController
  def index
    @fieldworks = Fieldwork.for_report.paginate(:page => params[:page], :per_page => 20)
  end

  def show
    @fieldwork = Fieldwork.find_by_fieldwork_id(params[:id])
    @conflicts = @fieldwork.latest_mege.try(:conflict_report)
  end
end
