class AppointmentSheetsController < ApplicationController

  def show
    @sheet = AppointmentSheet.new(params[:person])
    @person = @sheet.person
    @participant = @person.participant
    @participant_activity_plan = psc.build_activity_plan(@participant)
    @event_date = event_date
    @event_time = event_time
  end

  private

  def event_time
    event_activity = @participant_activity_plan.scheduled_activities.find do |sa|
      sa.date == params[:date] &&
      sa.event == @sheet.event_type.downcase.tr(' ','_') &&
      sa.person_id == @person.public_id
    end
    Time.parse(event_activity.activity_time).strftime("%l:%M %p") unless event_activity.blank?
  end


  def event_date
    Time.parse(params[:date]).strftime("%m/%d/%Y")
  end

end
