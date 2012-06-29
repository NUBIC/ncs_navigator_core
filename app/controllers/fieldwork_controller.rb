class FieldworkController < ApplicationController
  def index
    @fieldworks = Fieldwork.for_report.paginate(:page => params[:page], :per_page => 20)
  end

  def show
    @fieldwork = Fieldwork.find_by_fieldwork_id(params[:id])

    if @fieldwork.latest_merge.try(:conflict_report)
      @conflicts = JSON.parse(@fieldwork.latest_merge.conflict_report)
    end
  end
end
