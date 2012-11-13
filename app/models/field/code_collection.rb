module Field
  ##
  # An aggregation of {NcsCode}s, {NcsNavigator::Mdes::DispositionCode}s, and
  # other enumerations used by Field.
  class CodeCollection
    attr_reader :ncs_codes

    def last_modified
      [NcsCode.last_modified].max
    end

    def load_codes
      @ncs_codes = NcsCode.all
    end
  end
end
