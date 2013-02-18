module ResponseSetPrepopulation
  class LowIntensity < Populator
    def self.applies_to?(rs)
      rs.survey.title.include?('_QUE_LI')
    end

    def run
    end
  end
end
