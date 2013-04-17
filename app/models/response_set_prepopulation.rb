##
# Although responses in surveys are generally provided by study participants,
# there are a few reasons for Cases to provide responses before a participant
# (or, in the case of Field, a field worker) sees the response:
#
# 1. In multi-part instruments, responses in subsequent parts may replicate
#    previously collected data.  It is convenient to prepopulate those
#    responses with the previously collected responses.
# 2. Default values for some responses can be derived from operational data.
# 3. Handlebars helpers in survey text derive their values from response data.
#
# This module is the public interface to the prepopulation code.
module ResponseSetPrepopulation
  attr_accessor :logger

  POPULATORS = [
    Birth,
    ChildAndAdhoc,
    IntroductoryScript,
    LowIntensity,
    MustacheContext,
    NonInterview,
    ParticipantVerification,
    PbsParticipantVerification,
    PbsEligibilityScreener,
    Postnatal,
    PregnancyScreener,
    PregnancyVisit,
    TracingModule,
  ]

  ##
  # Instantiates and returns all appropriate populators for the given
  # ResponseSet.
  #
  # #populators_for places no expectations on a ResponseSet's associations.
  # However, _prepopulators_ may.
  #
  # @see ResponseSet#prepopulate
  def populators_for(response_set)
    POPULATORS.select { |p| p.applies_to?(response_set) }.map { |p| p.new(response_set) }
  end
end
