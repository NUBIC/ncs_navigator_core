class RecruitmentStrategy
  def self.recruitment_type_strategy(code)
    case code
    when 1
      EnhancedHousehold
    when 2
      ProviderBased
    when 3
      TwoTier
    when 4
      OriginalVanguard
    when 5
      ProviderBasedSubsample
    else
      self
    end
  end

  def self.two_tier_knowledgable?
    false
  end

  def self.pbs?
    false
  end

end

class TwoTier < RecruitmentStrategy
  def self.two_tier_knowledgable?
    true
  end
end

class ProviderBased < RecruitmentStrategy
end

class EnhancedHousehold < RecruitmentStrategy
end

class OriginalVanguard < RecruitmentStrategy
end

class ProviderBasedSubsample < RecruitmentStrategy
  def self.pbs?
    true
  end
end
