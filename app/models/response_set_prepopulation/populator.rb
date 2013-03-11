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
  end
end
