module ResponseSetPrepopulation
  class PbsEligibilityScreener < Populator
    include OldAccessMethods

    def self.applies_to?(rs)
      [
        /_PBSamplingScreen_/,
        /_PBSampScreenHosp_/
      ].any?{ |regex| rs.survey.title =~ regex }
    end

    def self.reference_identifiers
      [
        "prepopulated_mode_of_contact",
        "prepopulated_psu_id",
        "prepopulated_practice_num",
        "prepopulated_provider_id",
        "prepopulated_name_practice"
      ]
    end

    def run
      self.class.reference_identifiers.each do |reference_identifier|
        response_type = "string_value"

        if question = find_question_for_reference_identifier(reference_identifier)
          answer = question.answers.first
          value = case reference_identifier
                  when "prepopulated_mode_of_contact"
                    response_type = "answer"
                    answer = prepopulated_mode_of_contact(question)
                  when "prepopulated_psu_id"
                    NcsNavigatorCore.psu
                  when "prepopulated_practice_num"
                    person.provider.pbs_list.try(:practice_num) if person.provider
                  when "prepopulated_provider_id"
                    person.provider.public_id if person.provider
                  when "prepopulated_name_practice"
                    person.provider.name_practice if person.provider
                  else
                    nil
                  end

        build_response_for_value(response_type, response_set, question, answer, value)
        end
      end
      response_set
    end
  end
end
