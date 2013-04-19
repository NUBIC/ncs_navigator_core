# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: surveys
#
#  access_code            :string(255)
#  active_at              :datetime
#  api_id                 :string(255)
#  common_identifier      :string(255)
#  common_namespace       :string(255)
#  created_at             :datetime
#  css_url                :string(255)
#  custom_class           :string(255)
#  data_export_identifier :string(255)
#  description            :text
#  display_order          :integer
#  id                     :integer          not null, primary key
#  inactive_at            :datetime
#  instrument_type        :integer
#  instrument_version     :string(36)
#  reference_identifier   :string(255)
#  survey_version         :integer          default(0)
#  title                  :string(255)
#  updated_at             :datetime
#



require 'spec_helper'

require File.expand_path('../../shared/models/a_publicly_identified_record', __FILE__)

describe Survey do
  it_should_behave_like 'a publicly identified record' do
    let(:o1) { Factory(:survey) }
    let(:o2) { Factory(:survey) }
  end

  describe '#most_recent_for_access_code' do
    let!(:s0) { Factory(:survey, :access_code => 'foo', :survey_version => 0) }
    let!(:s1) { Factory(:survey, :access_code => 'foo', :survey_version => 1) }

    it "finds the most recent survey for a given access code" do
      Survey.most_recent_for_access_code('foo').should == s1
    end

    it "returns nil if code is blank" do
      Survey.most_recent_for_access_code(nil).should be_nil
    end
  end

  describe '.cache_recent' do
    let!(:s1) { Factory(:survey) }
    let!(:s2) { Factory(:survey) }
    let(:cache) { SurveyCache.new }

    before do
      cache.redis.flushdb
    end

    it 'caches uncached surveys' do
      Survey.cache_recent

      cache.get([s1, s2]).should == {
        s1 => s1.to_json,
        s2 => s2.to_json
      }
    end

    it 'renews cached surveys' do
      Survey.cache_recent

      # I'd like to use < 1 second waits here, but the maximum resolution of
      # Redis' key TTLs is one second.
      sleep 2
      Survey.cache_recent

      cache.ttl([s1, s2]).each do |ttl|
        ttl.should be_within(1.second).of(SurveyCache::TTL)
      end
    end
  end
end
