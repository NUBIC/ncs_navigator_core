module ResponseSetPrepopulation
  ##
  # Methods to perform data access.  These are provided solely for
  # compatibility.  Do NOT use them in new prepopulators.
  module OldAccessMethods
    def participant
      response_set.participant
    end

    def person
      response_set.person
    end

    def event
      response_set.instrument.event
    end

    def survey
      response_set.survey
    end

    def mode
      @mode ||= Instrument.capi
    end

    def mode=(mode)
      @mode = mode
    end

    def build_response_for_value(response_type, response_set, question, answer, value)
      if response_type == "answer"
        return if answer.nil?
        response_set.responses.build(:question => question, :answer => answer)
      else
        return if value.nil?
        response_set.responses.build(:question => question, :answer => answer, response_type.to_sym => value)
      end
    end

    def find_question_for_reference_identifier(reference_identifier)
      question = nil
      survey.sections_with_questions.each do |section|
        section.questions.each do |q|
          question = q if q.reference_identifier == reference_identifier
          break unless question.nil?
        end
        break unless question.nil?
      end
      question
    end

    # Find the answer with the matching reference identifier for question
    # @param [Question]
    # @param [String] reference_identifier matching answer
    # @return [Answer]
    def answer_for(question, ri)
      question.answers.select { |a| a.reference_identifier == ri.to_s }.first
    end

    def valid_response_exists?(data_export_identifier, which_response = :first)
      result = false
      if response = person.responses_for(data_export_identifier).send(which_response)
        reference_identifier = response.try(:answer).try(:reference_identifier).to_s
        result = true unless %w(neg_1 neg_2 neg_8).include?(reference_identifier)
      end
      result
    end

    ##
    # Determine if the mode of contact is CATI, CAPI, or PAPI
    # @return[Answer]
    def prepopulated_mode_of_contact(question)
      question.answers.select { |a| a.reference_identifier == mode_to_text }.first
    end

    ##
    # Translate the mode (an Integer) to a String. Used to determine
    # the Answer set in prepopulated_mode_of_contact
    # @return[String]
    def mode_to_text
      case mode
      when Instrument.papi
        'papi'
      when Instrument.cati
        'cati'
      when Instrument.capi
        'capi'
      else
        'capi'
      end
    end
  end
end
