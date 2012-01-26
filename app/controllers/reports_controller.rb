class ReportsController < ApplicationController

  def index
  end

  ##
  # Case Status Report
  # ------------------
  # Frequency  -
  #   Once a week Monday
  # Contents -
  #   SUID/participant ID
  #   Address (broken out into separate fields for Address 1, Address 2, City, State and zip)
  #   Phone Number
  #   Person Name (broken out into separate fields for First and Last)
  #   Date and Time of the next scheduled call attempt
  #   Date and Time of last call attempt
  #   Last Call Outcome
  #   PPG Status
  #   Instrument that is to be completed next
  #   Language we need to call in if other than English
  #   Use -
  #     Used to monitor weekly flow of cases.
  def case_status
    default_start_date = Date.today.to_s(:db)
    default_end_date   = 1.week.from_now.to_date.to_s(:db)

    @start_date = params[:start_date] || default_start_date
    @end_date   = params[:end_date]   || default_end_date

    if request.post?
      @outfile = "case_status_report_" + Time.now.strftime("%m-%d-%Y") + ".csv"

      reporter = Reporting::CaseStatusReport.new(psc, 
                  { :start_date => @start_date, :end_date => @end_date })
      csv_data = reporter.generate_report
      send_data csv_data,
        :type => 'text/csv; charset=iso-8859-1; header=present',
        :disposition => "attachment; filename=#{@outfile}"
    end


  end

end