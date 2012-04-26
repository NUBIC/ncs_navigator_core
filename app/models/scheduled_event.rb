# -*- coding: utf-8 -*-

class ScheduledEvent
  attr_accessor :date
  attr_accessor :event

  def initialize(opts)
    self.date  = opts[:date]
    self.event = opts[:event]
  end

end