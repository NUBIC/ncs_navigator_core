module FieldworkHelper
  def latest_merge_status(fw)
    fw.latest_merge_status ? fw.latest_merge_status.humanize : 'Unknown'
  end
end
