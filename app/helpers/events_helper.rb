module EventsHelper
  def event_window_fuzzy_time(open, close, date)
    if date < open
      "opens in #{distance_of_time_in_words(date,open)}"
    elsif date < close
      "closes in #{distance_of_time_in_words(date,close)}"
    else
      "closed #{distance_of_time_in_words(date,close)} ago"
    end
  end
end
