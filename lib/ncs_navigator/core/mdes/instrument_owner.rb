module NcsNavigator::Core::Mdes
  module InstrumentOwner
    extend ActiveSupport::Concern

    module InstanceMethods
      ##
      # @return [Array<Instrument>] where the instrument has an associated Survey
      def instruments_with_surveys
        self.instruments.select { |i| !i.survey.nil? }
      end

      ##
      # The unique survey titles from the instruments.
      # @return [Array<String>] Instrument Survey titles
      def instrument_survey_titles
        instrument_response_sets.collect{ |rs| rs.survey.title }.uniq
      end

      ##
      # All the response sets associated with all the instruments.
      # @return [Array<ResponseSet>]
      def instrument_response_sets
        self.instruments.collect{ |i| i.response_sets }.flatten.compact
      end
    end

  end
end