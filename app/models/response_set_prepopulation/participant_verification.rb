module ResponseSetPrepopulation
  class ParticipantVerification
    def self.applies_to?(rs)
      rs.survey.title.include?('_ParticipantVerif_')
    end

    def run
    end
  end
end
