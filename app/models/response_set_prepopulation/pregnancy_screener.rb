module ResponseSetPrepopulation
  class PregnancyScreener < Populator
    include OldAccessMethods

    def self.applies_to?(rs)
      rs.survey.title.include?('_PregScreen_')
    end

    def run
    end
  end
end
