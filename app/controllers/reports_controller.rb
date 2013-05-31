# -*- coding: utf-8 -*-


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

      reporter = Reports::CaseStatusReport.new(psc,
                  { :start_date => @start_date, :end_date => @end_date })
      csv_data = reporter.generate_report
      send_data csv_data,
        :type => 'text/csv; charset=iso-8859-1; header=present',
        :disposition => "attachment; filename=#{@outfile}"
    end
  end

  ##
  # Returns all the participants known to have a birth in the future
  def upcoming_births
    @pregnant_participants = Participant.upcoming_births.select { |participant| participant.known_to_be_pregnant? }.sort_by { |e| e.due_date.to_s }
  end

  ##
  # Return all participants with the current given PpgStatus
  def ppg_status
    params[:page] ||= 1

    default_ppg_status_code = "1"
    @ppg_status_code = params[:ppg_status_code] || default_ppg_status_code

    result = PpgStatusHistory.current_ppg_status.with_status(@ppg_status_code).select("distinct ppg_status_histories.*, people.last_name").joins(
      "inner join participant_person_links on participant_person_links.participant_id = ppg_status_histories.participant_id
       inner join people on people.id = participant_person_links.person_id"
    ).where("participant_person_links.relationship_code = '1'").order("people.last_name")
    @ppg_statuses = result.paginate(:page => params[:page], :per_page => 20)

    respond_to do |format|
      format.html # index.html.haml
      format.json { render :json => result.all }
    end
  end

  def number_of_consents_by_type

  end

  def consented_participants
    params[:page] ||= 1
    result = ParticipantConsent.where(:consent_type_code => params[:consent_type_code]).select("distinct participant_consents.*, people.last_name").joins(
      "inner join participant_person_links on participant_person_links.participant_id = participant_consents.participant_id
       inner join people on people.id = participant_person_links.person_id"
    ).where("participant_person_links.relationship_code = '1'").order("people.last_name")
    @consents = result.paginate(:page => params[:page], :per_page => 20)
  end

end