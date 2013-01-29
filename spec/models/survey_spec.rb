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

  context "more than one Survey having the same title", :slow do

    before(:each) do
      Survey.destroy_all
      count = 0
      Dir["#{Rails.root}/spec/fixtures/surveys/*.rb"].sort.each do |f|
        $stdout = StringIO.new
        Surveyor::Parser.parse File.read(f)
        $stdout = STDOUT
        count += 1
      end

      Survey.count.should == count
    end

    describe "#most_recent_for_access_code" do
      it "finds the most recent survey for a given access code" do
        title = "INS_QUE_LIPregNotPreg_INT_LI_P2_V2.0"
        access_code = Survey.to_normalized_string(title)

        Survey.most_recent_for_access_code(access_code).should ==
          Survey.order(:survey_version).where(:access_code => access_code).last
      end
      it "returns nil if code is blank" do
        Survey.most_recent_for_access_code("").should be_nil
      end
    end

    it 'finds all the most recent surveys' do
      # expected = all survey titles in #{Rails.root}/spec/fixtures/surveys directory
      expected = [
        'INS_QUE_LIPregNotPreg_INT_LI_P2_V2.0',
        'INS_QUE_PregVisit1_INT_EHPBHI_P2_V2.0'
      ]

      Survey.most_recent.order(:title).map(&:title).should == expected
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
