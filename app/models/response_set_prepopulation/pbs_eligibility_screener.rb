module ResponseSetPrepopulation
  class PbsEligibilityScreener < Populator
    def self.applies_to?(rs)
      rs.survey.title.include?('_PBSamplingScreen_')
    end

    def run
    end
  end
end
