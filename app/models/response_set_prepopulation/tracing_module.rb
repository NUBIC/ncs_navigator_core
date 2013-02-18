module ResponseSetPrepopulation
  class TracingModule < Populator
    def self.applies_to?(rs)
      rs.survey.title.include?('_Tracing_')
    end

    def run
    end
  end
end
