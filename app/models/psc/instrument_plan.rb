module Psc
  ##
  # PSC scheduled activities labeled with `instrument:` and possibly
  # `references:` not only imply {Instrument}s and {Survey}s, but they also
  # imply an ordered hierarchy for survey-taking.
  #
  # This class, along with {InstrumentPlanCollection}, reifies that hierarchy.
  #
  # The instrument plan hierarchy always has one root and is always at most two
  # levels deep.  The bottom level consists of surveys that reference the root;
  # the referrers are ordered according to their activity's "order" label.
  class InstrumentPlan < Struct.new(:root, :surveys)
    def initialize(*args)
      super

      self.surveys ||= []
    end

    def id
      root.try(:fingerprint)
    end

    def order
      surveys.sort_by! { |s| s.order.to_s }
    end
  end
end
