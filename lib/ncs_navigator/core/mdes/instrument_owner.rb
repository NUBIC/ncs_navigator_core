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
      # @return [Array<String>] Instrument Survey titles
      def instrument_survey_titles
        self.instruments.collect{ |i| i.response_sets }.flatten.compact.collect{ |rs| rs.survey.title }.uniq
      end
    end

  end
end