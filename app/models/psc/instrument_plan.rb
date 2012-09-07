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
  class InstrumentPlan < Struct.new(:root, :activities)
    def initialize(*args)
      super

      self.activities ||= []
    end

    def order
      activities.sort_by! { |a| a.order_label.to_s }
    end

    def surveys
      activities.map { |a| [a.survey, a.referenced_survey] }.flatten.compact
    end
  end
end
