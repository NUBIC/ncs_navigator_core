class NonInterviewReportsController < ApplicationController
  # GET /non_interview_reports
  # GET /non_interview_reports.json
  def index
    @non_interview_reports = NonInterviewReport.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @non_interview_reports }
    end
  end

  # GET /non_interview_reports/1
  # GET /non_interview_reports/1.json
  def show
    @non_interview_report = NonInterviewReport.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @non_interview_report }
    end
  end

  # GET /non_interview_reports/new
  # GET /non_interview_reports/new.json
  def new
    @non_interview_report = NonInterviewReport.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @non_interview_report }
    end
  end

  # GET /non_interview_reports/1/edit
  def edit
    @non_interview_report = NonInterviewReport.find(params[:id])
  end

  # POST /non_interview_reports
  # POST /non_interview_reports.json
  def create
    @non_interview_report = NonInterviewReport.new(params[:non_interview_report])

    respond_to do |format|
      if @non_interview_report.save
        format.html { redirect_to @non_interview_report, :notice => 'Non interview report was successfully created.' }
        format.json { render :json => @non_interview_report, :status => :created, :location => @non_interview_report }
      else
        format.html { render :action => "new" }
        format.json { render :json => @non_interview_report.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /non_interview_reports/1
  # PUT /non_interview_reports/1.json
  def update
    @non_interview_report = NonInterviewReport.find(params[:id])

    respond_to do |format|
      if @non_interview_report.update_attributes(params[:non_interview_report])
        format.html { redirect_to @non_interview_report, :notice => 'Non interview report was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @non_interview_report.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /non_interview_reports/1
  # DELETE /non_interview_reports/1.json
  def destroy
    @non_interview_report = NonInterviewReport.find(params[:id])
    @non_interview_report.destroy

    respond_to do |format|
      format.html { redirect_to non_interview_reports_url }
      format.json { head :ok }
    end
  end
end
