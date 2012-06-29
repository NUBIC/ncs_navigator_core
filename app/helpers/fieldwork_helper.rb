module FieldworkHelper
  STATE_KEYS = %w(current original proposed)

  def latest_merge_status(fw)
    fw.latest_merge_status ? fw.latest_merge_status.humanize : 'Waiting for field client'
  end

  ##
  # Recursively sorts keys in a conflict report.  Sorting is done using
  # lexicographical ordering.
  #
  # The last level of the report (a state => value mapping) is not sorted,
  # because the conflict report view accesses that mapping by state key.
  #
  # @see Merge
  def ordered_conflict_report(report)
    report.keys.sort.map do |k|
      if report[k].keys.sort == STATE_KEYS
        [k, report[k]]
      else
        [k, ordered_conflict_report(report[k])]
      end
    end
  end
end
