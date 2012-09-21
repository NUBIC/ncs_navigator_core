class MergesController < ApplicationController
  before_filter :load_fieldwork

  def latest
    @conflicts = @fieldwork.latest_merge.try(:conflict_report)

    render 'show'
  end

  def show
    @conflicts = @fieldwork.merges.find(params[:id]).conflict_report
  end

  def load_fieldwork
    @fieldwork = Fieldwork.find_by_fieldwork_id(params[:fieldwork_id])

    raise ActiveRecord::RecordNotFound if !@fieldwork
  end
end
