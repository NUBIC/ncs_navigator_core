# -*- coding: utf-8 -*-

module ListHelper
  ##
  # Sort array of dates and times returned from #started_at method
  # @param [Array<[Array<Date, String>]>]
  # @return [Array<[Array<Date, String>]>]
  def sort_by_started_at(list)
    list.sort_by do |x|
      sd, st = x.started_at
      [ sd || Date.new(2111,1,1), st || "23:59" ]
    end
  end

end
