# -*- coding: utf-8 -*-

require 'spec_helper'
require "#{Rails.root}/lib/recruitment_strategy"

describe RecruitmentStrategy do

  context 'given a code from the recruit_type_cl1 code list' do

    describe '.recruitment_type_strategy' do

      it 'returns EnhancedHousehold for 1' do
        RecruitmentStrategy.recruitment_type_strategy(1).should == EnhancedHousehold
      end

      it 'returns ProviderBased for 2' do
        RecruitmentStrategy.recruitment_type_strategy(2).should == ProviderBased
      end

      it 'returns TwoTier for 3' do
        RecruitmentStrategy.recruitment_type_strategy(3).should == TwoTier
      end

      it 'returns OriginalVanguard for 4' do
        RecruitmentStrategy.recruitment_type_strategy(4).should == OriginalVanguard
      end

      it 'returns ProviderBasedSubsample for 5' do
        RecruitmentStrategy.recruitment_type_strategy(5).should == ProviderBasedSubsample
      end

    end

    describe '.two_tier_knowledgable' do
      it 'returns nil' do
        RecruitmentStrategy.should_not be_two_tier_knowledgable
      end
    end

  end
end

describe TwoTier do
  describe '.two_tier_knowledgable' do
    it 'returns true' do
      TwoTier.should be_two_tier_knowledgable
    end
  end

end

describe ProviderBased do
  describe '.two_tier_knowledgable' do
    it 'returns false' do
      ProviderBased.should_not be_two_tier_knowledgable
    end
  end
end

describe EnhancedHousehold do
  describe '.two_tier_knowledgable?' do
    it 'returns false' do
      EnhancedHousehold.should_not be_two_tier_knowledgable
    end
  end
end

describe OriginalVanguard do
  describe '.two_tier_knowledgable?' do
    it 'returns false' do
      OriginalVanguard.should_not be_two_tier_knowledgable
    end
  end
end

describe ProviderBasedSubsample do
  describe '.two_tier_knowledgable?' do
    it 'returns false' do
      ProviderBasedSubsample.should_not be_two_tier_knowledgable
    end
  end
end
