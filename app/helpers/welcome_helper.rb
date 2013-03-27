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

  def place_activities_with_blank_times_at_the_bottom_of_list(activities)
    activities.sort{ |a1, a2|( a1.send(:activity_time) && a2.send(:activity_time) ) ?
                               a1.send(:activity_time) <=> a2.send(:activity_time) :
                             ( a1.send(:activity_time) ? -1 : 1 ) }
  end

  def convert_24_hour_time_to_am_pm_time(time)
    Time.strptime(time, '%H:%M').strftime('%l:%M %p')
  end

end
