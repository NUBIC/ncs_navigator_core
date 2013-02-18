module ResponseSetPrepopulation
  class PregnancyVisit < Populator
    def self.applies_to?(rs)
      %w(PregVisit1 PregVisit2).any? { |t| rs.survey.title.include?("_#{t}_") }
    end

    def run
    end
  end
end
