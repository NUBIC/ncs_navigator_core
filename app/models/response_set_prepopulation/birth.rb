module ResponseSetPrepopulation
  class Birth < Populator
    def self.applies_to?(rs)
      rs.survey.title.include?('_Birth_')
    end

    def run
    end
  end
end
