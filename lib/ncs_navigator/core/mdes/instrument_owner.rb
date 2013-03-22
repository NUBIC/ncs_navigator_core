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
        Survey.select(:title).joins(:response_sets).where('response_sets.instrument_id' => instrument_ids).map(&:title)
      end
    end

  end
end