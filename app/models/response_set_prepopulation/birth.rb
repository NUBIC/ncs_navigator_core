module ResponseSetPrepopulation
  class Birth
    def self.applies_to?(rs)
      rs.survey.title.include?('_Birth_')
    end

    def run
    end
  end
end
