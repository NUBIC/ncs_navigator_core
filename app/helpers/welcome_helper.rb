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

end
