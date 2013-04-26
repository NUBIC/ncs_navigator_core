# -*- coding: utf-8 -*-


module WelcomeHelper

  def activities(json_response)
    json = ActiveSupport::JSON.decode(json_response)
    result = { "dates" => Array.new }
    json["rows"].each do |row|
      date = row['scheduled_date']
      if !result['dates'].include?(date)
        result['dates'] << date
      end

    end
    result
  end

  def sort_activities_chronologically_with_blank_times_at_the_bottom_of_list(activities)
    convert_time_to_integer = Proc.new { |time| time.delete(":").to_i }

    sorted  = activities.select  { |act| act.activity_time }
                        .sort_by { |act|  convert_time_to_integer.call(act.activity_time) }

    empties = activities.select { |act| act.activity_time.nil?  }

    sorted + empties
  end

  def convert_24_hour_time_to_am_pm_time(time)
    Time.strptime(time, '%H:%M').strftime('%l:%M %p')
  end

end
