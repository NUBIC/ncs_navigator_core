require 'spec_helper'
require 'redis'

module Field
  describe SurveyCache do
    let(:cache) { SurveyCache.new }
    let(:s1) { Factory(:survey) }
    let(:s2) { Factory(:survey) }
    let(:s3) { Factory(:survey) }

    before do
      Rails.application.redis.flushdb
    end

    describe '#put' do
      it "caches a survey's JSON representation" do
        cache.put([s1, s2, s3])

        cache.get([s1, s2, s3]).should == {
          s1 => s1.to_json,
          s2 => s2.to_json,
          s3 => s3.to_json
        }
      end

      it "puts [] without raising a Redis error" do
        lambda { cache.put([]) }.should_not raise_error(Redis::CommandError)
      end

      it "sets an expiration time" do
        cache.put([s1])
        cache.ttl([s1]).first.should be_within(1.second).of(1.hour)
      end
    end

    describe '#get' do
      it 'returns nil if no representation is cached for the given survey' do
        cache.put([s1, s3])

        cache.get([s1, s2, s3]).should == {
          s1 => s1.to_json,
          s2 => nil,
          s3 => s3.to_json
        }
      end

      it "returns {} when given []" do
        cache.get([]).should be_empty
      end
    end

    describe '#peek' do
      let(:result) { cache.peek([s1, s2]) }

      before do
        cache.put([s1])
      end

      it 'maps a cached survey to true' do
        result[s1].should be_true
      end

      it 'maps a non-cached survey to false' do
        result[s2].should be_false
      end
    end

    describe '#renew' do
      it "renews surveys' stays in cache" do
        cache.put([s1])
        sleep 2
        cache.renew([s1])

        cache.ttl([s1]).first.should be_within(1.second).of(1.hour)
      end
    end

    describe '#delete' do
      it 'deletes cached JSON for a survey' do
        cache.put([s1])
        cache.delete([s1])

        cache.get([s1]).should == {
          s1 => nil
        }
      end

      it "deletes [] without raising a Redis error" do
        lambda { cache.delete([]) }.should_not raise_error(Redis::CommandError)
      end
    end
  end
end
