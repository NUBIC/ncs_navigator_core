# -*- coding: utf-8 -*-

module ListHelper
  ##
  # Sort array of dates and times returned from #started_at method
  # @param [Array<[Array<Date, String>]>]
  # @return [Array<[Array<Date, String>]>]
  def sort_by_started_at(list)
    list.sort_by { |x|
      sd, st = x.started_at
      [ sd || Date.new(1911,1,1), st || "23:59" ]
    }.reverse!
  end

end
