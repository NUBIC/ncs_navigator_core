require 'ncs_navigator/core'

module Field
  class ScheduledActivityReport < Psc::ScheduledActivityReport
    include Psc::ModelDerivation

    def process
      derive_models
    end
  end
end
