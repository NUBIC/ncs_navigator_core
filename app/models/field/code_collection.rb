module Field
  ##
  # An aggregation of {NcsCode}s, {NcsNavigator::Mdes::DispositionCode}s, and
  # other enumerations used by Field.
  class CodeCollection
    include NcsNavigator::Mdes

    attr_reader :disposition_codes
    attr_reader :ncs_codes

    def last_modified
      [DispositionCode.last_modified, NcsCode.last_modified].compact.max
    end

    def load_codes
      @disposition_codes = NcsNavigatorCore.configuration.mdes.disposition_codes
      @ncs_codes = NcsCode.all
    end
  end
end
