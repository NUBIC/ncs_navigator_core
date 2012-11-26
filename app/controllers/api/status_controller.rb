class Api::StatusController < ActionController::Base
  include NcsNavigator::Core::StatusChecks

  def show
    report = Report.new
    report.run

    render :json => report.to_json, :status => report.failed? ? :internal_server_error : :ok
  end
end
