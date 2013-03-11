require 'ncs_navigator/core'

module ResponseSetPrepopulation
  ##
  # Fills in text used by Handlebars helpers in surveys.
  #
  # Values for Handlebars helpers are derived from specially marked questions
  # in the response set.  This lets us lock helper expansions.
  class MustacheContext < Populator
    include NcsNavigator::Core::Surveyor::SurveyTaker

    ##
    # The participant associated with the response set being populated.
    #
    # Only available after #load_data has been invoked.
    attr_reader :participant

    ##
    # The person associated with the response set being populated.
    #
    # Only available after #load_data has been invoked.
    attr_reader :person

    ##
    # The instrument associated with the response set being populated.
    #
    # Only available after #load_data has been invoked.
    attr_reader :instrument

    ##
    # This populator can be used on any response set.
    def self.applies_to?(rs)
      true
    end

    def run
      ctx = NcsNavigator::Core::Mustache::InstrumentContext.new(response_set)

      respond(response_set) do |r|
        helper_questions do |reference_identifier, method|
          if !ctx.respond_to?(method)
            raise "#{ctx.class} does not supply an implementation of #{method}"
          end

          r.answer reference_identifier, :value => ctx.send(method)
        end
      end
    end

    private

    def helper_questions
      qs = response_set.survey.questions.for_mustache_helpers

      qs.each do |q|
        ri = q.reference_identifier

        yield ri, ri.sub('helper_', '')
      end
    end
  end
end
