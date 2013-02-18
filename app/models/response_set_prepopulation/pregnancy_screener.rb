module ResponseSetPrepopulation
  class PregnancyScreener < Populator
    def self.applies_to?(rs)
      rs.survey.title.include?('_PregScreen_')
    end

    def run
    end
  end
end
