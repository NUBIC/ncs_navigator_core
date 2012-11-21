# -*- coding: utf-8 -*-


require 'spec_helper'
require "#{Rails.root}/lib/recruitment_strategy"

describe RecruitmentStrategy do

  context 'given a code from the RECRUIT_TYPE_CL1 code list' do

    describe '.for_code' do
      it 'returns EnhancedHousehold for 1' do
        RecruitmentStrategy.for_code(1).should be_instance_of(EnhancedHousehold)
      end

      it 'returns ProviderBased for 2' do
        RecruitmentStrategy.for_code(2).should be_instance_of(ProviderBased)
      end

      it 'returns TwoTier for 3' do
        RecruitmentStrategy.for_code(3).should be_instance_of(TwoTier)
      end

      it 'returns OriginalVanguard for 4' do
        RecruitmentStrategy.for_code(4).should be_instance_of(OriginalVanguard)
      end

      it 'returns ProviderBasedSubsample for 5' do
        RecruitmentStrategy.for_code(5).should be_instance_of(ProviderBasedSubsample)
      end

    end

  end
end

describe TwoTier do
  describe '#two_tier_knowledgable?' do
    it 'returns true' do
      TwoTier.new.should be_two_tier_knowledgable
    end
  end

end

describe ProviderBased do
  describe '#two_tier_knowledgable?' do
    it 'returns false' do
      ProviderBased.new.should_not be_two_tier_knowledgable
    end
  end
end

describe EnhancedHousehold do
  describe '.two_tier_knowledgable?' do
    it 'returns false' do
      EnhancedHousehold.new.should_not be_two_tier_knowledgable
    end
  end
end

describe OriginalVanguard do
  describe '.two_tier_knowledgable?' do
    it 'returns false' do
      OriginalVanguard.new.should_not be_two_tier_knowledgable
    end
  end
end

describe ProviderBasedSubsample do
  describe '.two_tier_knowledgable?' do
    it 'returns false' do
      ProviderBasedSubsample.new.should_not be_two_tier_knowledgable
    end
  end
end
