# -*- coding: utf-8 -*-


##
# A DSL for answering questions on Surveyor surveys.  See the *DataExtractor
# specs for example usage.
module SurveyCompletion
  ##
  # Invoke this to start answering questions on a survey, storing the
  # responses in the given response_set.
  #
  # This method yields an object for storing responses.
  def take_survey(survey, response_set)
    yield Answerer.new(survey, response_set)
  end

  class Answerer
    def initialize(survey, response_set)
      @survey = survey
      @rs = response_set
    end

    def str(identifier, answer)
      for_each_match(identifier) do |q, section|
        create_fill_in_response(q, :string_value, answer, section)
      end
    end

    def int(identifier, answer)
      for_each_match(identifier) do |q, section|
        create_fill_in_response(q, :integer_value, answer, section)
      end
    end

    def date(identifier, answer)
      for_each_match(identifier) do |q, section|
        create_fill_in_response(q, :datetime_value, answer, section)
      end
    end

    def choice(identifier, answer)
      for_each_match(identifier) do |q, section|
        val = answer.local_code.to_s
        # handle negative value reference identifier
        val = val.gsub("-", "neg_") if answer.local_code.to_i < 0
        create_choice_response(q, :reference_identifier, val, section)
      end
    end

    def yes(identifier)
      for_each_match(identifier) do |q, section|
        create_choice_response(q, :text, 'Yes', section)
      end
    end

    def no(identifier)
      for_each_match(identifier) do |q, section|
        create_choice_response(q, :text, 'No', section)
      end
    end

    def refused(identifier)
      for_each_match(identifier) do |q, section|
        create_choice_response(q, :text, 'Refused', section)
      end
    end

    def dont_know(identifier)
      for_each_match(identifier) do |q, section|
        create_choice_response(q, :text, "Don't know", section)
      end
    end

    def for_each_match(identifier)
      @survey.sections.each do |section|
        section.questions.each do |q|
          yield q, section if q.data_export_identifier == identifier
        end
      end
    end

    def create_fill_in_response(q, k, v, section)
      rc = case k
           when :datetime_value; 'date'
           when :integer_value; 'integer'
           when :string_value; 'string'
           end

      answer = q.answers.detect { |a| a.response_class == rc }

      assert answer, q, v, section

      create_response(q, answer, section, k => v)
    end

    def create_choice_response(q, k, v, section)
      answer = q.answers.detect { |a| a.response_class == 'answer' && a.send(k) == v }

      assert answer, q, { k => v }, section

      create_response(q, answer, section)
    end

    def create_response(q, a, section, options = {})
      Factory(:response, options.merge(:survey_section_id => section.id,
                                       :question_id => q.id,
                                       :answer_id => a.id,
                                       :response_set_id => @rs.id))

    end

    def assert(answer, question, criterion, section)
      if answer.nil?
        raise <<-END
An answer could not be found.

Question: #{question.inspect}
Criterion: #{criterion.inspect}
Section: #{section.inspect}
        END
      end
    end
  end
end
