class Api::EventsController < ApiController
  def index
    range = params[:scheduled_date]
    codes = params[:types].try(:map, &:to_i)
    data_collectors = params[:data_collectors]

    begin
      report = Reports::EventReport.new(codes, data_collectors, range, psc)
      report.run

      respond_with report, :serializer => EventReportSerializer
    rescue Reports::ScopeTooBroadError
      render :nothing => true, :status => :bad_request
    end
  end
end
