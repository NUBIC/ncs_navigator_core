module ResponseSetPrepopulation
  class LowIntensity < Populator
    def reference_identifiers
      [
        "prepopulated_ppg_status",
      ]
    end
    
    def self.applies_to?(rs)
      rs.survey.title.include?('_QUE_LI')
    end

    def run
        reference_identifiers.each do |reference_identifier|
        if question = find_question_for_reference_identifier(reference_identifier)
          answer = question.answers.first
          value = case reference_identifier
                  when "prepopulated_ppg_status"
                    response_type = "integer_value"
                    person.ppg_status
                  else
                    # TODO: handle other prepopulated fields
                    response_type = "string_value"
                    nil
                  end
          response_set.responses.build(:question => question, :answer => answer, response_type.to_sym => value)
        end
      end
      response_set
    end
  end
end
