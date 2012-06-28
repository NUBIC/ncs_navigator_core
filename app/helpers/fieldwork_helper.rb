module FieldworkHelper
  def latest_merge_status(fw)
    fw.latest_merge_status ? fw.latest_merge_status.humanize : 'Unknown'
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
    state_keys = %w(current original proposed)

    report.keys.sort.map do |k|
      if report[k].keys.sort == state_keys
        [k, report[k]]
      else
        [k, ordered_conflict_report(report[k])]
      end
    end
  end
end
