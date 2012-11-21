require 'ncs_navigator/core'

module Field
  class ScheduledActivityReport < Psc::ScheduledActivityReport
    include Psc::ModelDerivation
  end
end
