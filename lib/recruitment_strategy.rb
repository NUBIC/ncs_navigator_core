# -*- coding: utf-8 -*-

require 'patient_study_calendar'

##
# From Cases' point of view, a recruitment strategy is usually just a name and
# does not require special treatment.
#
# Sometimes, however, they do.
#
# In addition to strategy instantiation, this module defines useful predicates
# for those special times.
#
# @private
module RecruitmentStrategy
  def for_code(code)
    strat = case code
            when 1; EnhancedHousehold
            when 2; ProviderBased
            when 3; TwoTier
            when 4; OriginalVanguard
            when 5; ProviderBasedSubsample
            else raise "Unknown recruitment type code #{code}"
            end

    strat.new
  end

  module_function :for_code

  ##
  # Does the strategy have two tiers?
  def two_tier_knowledgable?
    false
  end

  ##
  # Does the strategy use provider-based sampling?
  def pbs?
    false
  end

  ##
  # The event templates that will be made available to field clients.
  #
  # These should be names of study segments in PSC.  See e.g.
  # {PatientStudyCalendar::HIGH_INTENSITY_PREGNANCY_VISIT_1}.
  def field_event_templates
    []
  end
end

class TwoTier
  include RecruitmentStrategy

  def two_tier_knowledgable?
    true
  end
end

class ProviderBased
  include RecruitmentStrategy
end

class EnhancedHousehold
  include RecruitmentStrategy
end

class OriginalVanguard
  include RecruitmentStrategy
end

class ProviderBasedSubsample
  include RecruitmentStrategy

  def pbs?
    true
  end

  def field_event_templates
    [
      PatientStudyCalendar::HIGH_INTENSITY_PREGNANCY_VISIT_1,
      PatientStudyCalendar::PBS_ELIGIBILITY_SCREENER
    ]
  end
end
