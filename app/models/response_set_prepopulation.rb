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
    LowIntensity,
    MustacheContext,
    NonInterview,
    ParticipantVerification,
    PbsParticipantVerification,
    PbsEligibilityScreener,
    PregnancyScreener,
    PregnancyVisit,
    TracingModule,
  ]

  ##
  # Instantiates and returns all appropriate populators for the given
  # ResponseSet.
  #
  # The given ResponseSet MUST satisfy all of the below criteria:
  #
  # 1. It must reference a persisted {Survey}.
  # 2. It must reference a persisted {Participant}.
  # 3. It must reference an {Instrument}.
  #
  # An ArgumentError will be raised if the given ResponseSet does not satisfy
  # all of the above criteria.
  #
  # The returned populators will all respond to #run.  Each populator will
  # build zero or more Responses associated with the ResponseSet.
  #
  # When using this method, you SHOULD ensure that the ResponseSet's Survey,
  # Participant, and Instrument associations are eager-loaded.
  def populators_for(response_set)
    POPULATORS.select { |p| p.applies_to?(response_set) }.map { |p| p.new(response_set) }
  end
end
