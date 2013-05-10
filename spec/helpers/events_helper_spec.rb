# -*- coding: utf-8 -*-

require 'spec_helper'

describe EventsHelper do
  describe '#event_window_fuzzy_time' do
    it 'returns "opens in *time* " when the date is before the open' do
      event_window_fuzzy_time(
                              Date.parse("2012-05-10"),
                              Date.parse("2012-05-20"),
                              Date.parse("2012-05-9")).should == "opens in #{distance_of_time_in_words(Date.parse("2012-05-9"),Date.parse("2012-05-10"))}"
    end
    it 'returns "closes in *time* when date is between open and close"' do
      event_window_fuzzy_time(
                              Date.parse("2012-05-10"),
                              Date.parse("2012-05-20"),
                              Date.parse("2012-05-15")).should == "closes in #{distance_of_time_in_words(Date.parse("2012-05-15"),Date.parse("2012-05-20"))}"
    end
    it 'returns "closed *time* ago" when the date is after close' do
      event_window_fuzzy_time(
                              Date.parse("2012-05-10"),
                              Date.parse("2012-05-20"),
                              Date.parse("2012-05-21")).should == "closed #{distance_of_time_in_words(Date.parse("2012-05-20"),Date.parse("2012-05-21"))} ago"
    end
  end
end
