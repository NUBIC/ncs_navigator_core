module FieldworkHelper
  STATE_KEYS = %w(current original proposed)

  def latest_merge_status(fw)
    fw.latest_merge_status ? fw.latest_merge_status.humanize : 'Waiting for field client'
  end

end
