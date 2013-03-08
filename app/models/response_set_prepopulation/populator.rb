module ResponseSetPrepopulation
  ##
  # Provides initialization behavior for {ResponseSet} prepopulators.
  #
  # Also loosely defines what a populator should act like.
  class Populator
    attr_reader :response_set

    ##
    # Whether this populator should be applied to the given {ResponseSet}.
    def self.applies_to?(rs)
      false
    end

    def initialize(rs)
      @response_set = rs
    end

    ##
    # Runs the populator on its {ResponseSet}.
    #
    # The base implementation does nothing.
    def run
    end

    def participant
    end

    def person
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
  end
end
