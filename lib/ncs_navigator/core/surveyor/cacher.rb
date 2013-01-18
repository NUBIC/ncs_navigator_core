module NcsNavigator::Core::Surveyor
  class Cache
    attr_reader :redis

    def self.refresh
      Survey.select([:id]).each do |s|
        CacheWorker.perform_async(s.id)
      end
    end

    def initialize(redis)
      @redis = redis
    end

    def purge(survey)
      redis.del key(survey)
    end

    def cache(survey, json)
      redis.set key(survey), json
    end

    def get(survey)
      redis.get key(survey)
    end

    def key(survey)
      "nubic:ncs_navigator_core:#{Rails.env}:survey_json:#{survey.id}"
    end
  end

  class CacheWorker
    include Sidekiq::Worker

    def perform(survey_id)
      c = Cache.new(Rails.application.redis)
      s = Survey.find(survey_id)

      c.purge(s)
      json = Survey.find(survey_id).as_json.to_json
      c.cache(s, json)
    end
  end
end
