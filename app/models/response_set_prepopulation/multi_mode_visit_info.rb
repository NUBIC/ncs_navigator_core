module ResponseSetPrepopulation

  class MultiModeVisitInfo < Populator
    include NcsNavigator::Core::Surveyor::SurveyTaker

    def self.applies_to?(rs)
      rs.survey.title.include?('_MultiModeVisitInfo_')
    end

    def run
      respond(@response_set) do |r|
        r.answer "prepopulated_mode_of_contact", mode_to_text(@response_set.instrument.instrument_mode_code)
        r.answer "prepopulate_is_birth_or_subsequent_event", @response_set.instrument.event.postnatal?.to_s
      end
    end

    # @todo move this when prepopulators get refactored
    def mode_to_text(mode)
      case mode
      when Instrument.papi
        'papi'
      when Instrument.cati
        'cati'
      when Instrument.capi
        'capi'
      end
    end
  end
end
