require 'ncs_navigator/core'

module Field
  class ScheduledActivityReport < Psc::ScheduledActivityReport
    include Adoption
    include Psc::ModelDerivation
    include Psc::ModelResolution
    include ReportSerialization

    def process
      derive_models
      reify_models
    end
  end
end
