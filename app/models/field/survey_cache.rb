module Field
  ##
  # Caches JSON representations of {Survey}s in Redis.
  #
  # Synopsis
  # --------
  #
  #     c = Field::SurveyCache.new
  #     svs = Survey.where(conditions)
  #
  #     while do
  #       surveys = c.get(svs)
  #       if surveys.all? { |s, json| json }
  #         break
  #       else
  #         missing = surveys.select { |s, json| !json }.map(&:first)
  #         c.put(missing)
  #       end
  #     end
  #
  #     do_something_with_surveys(surveys)
  #
  #     # keep the surveys in cache
  #     c.renew(svs)
  #
  #     # time passes...
  #     c.delete(svs)
  #
  #
  # Expiration
  # ----------
  #
  # When cached, survey keys are set to expire in {TTL} seconds.  Surveys may
  # be renewed by calling #renew.
  #
  #
  # A tip
  # -----
  #
  # If you need to use the result of {#get} in another JSON structure, don't
  # parse the result -- that's very expensive in time and space.
  # Instead, wrap it in {Field::JsonSurvey}, which provides a much more direct
  # path for JSON serialization.
  class SurveyCache
    TTL = SurveyCacheWorker.period * 2

    attr_reader :redis

    def initialize(redis = Rails.application.redis)
      @redis = redis
    end

    ##
    # Retrieves a cached version of the given surveys by API ID.
    #
    # Returns a mapping of Survey to cached result.  If no result is available
    # for the given survey, that survey will be present in the returned
    # mapping but will map to nil.
    #
    # This method assumes that a survey with a given API ID is immutable: that
    # is, changing a survey (which includes changes to any of its
    # constituent entities) results in a survey with a new API ID.  Currently,
    # nothing enforces that except the convention of "load new surveys via a
    # task that always makes new survey objects".
    #
    # Janky, yes, but in lieu of a useful content fingerprinting system for
    # Surveyor data, there's not much else we can do.
    #
    # (Incorporating timestamps *might* help with this, but you'd still have
    # to check timestamps on the survey and all of its associated entities,
    # which is tedious.)
    #
    # @return [Hash<Survey, [String, nil]>] a survey -> JSON mapping
    def get(surveys)
      return {} if surveys.empty?

      keys = keys_for(surveys)
      data = redis.mget(keys)

      surveys.each.with_object({}).with_index do |(s, h), i|
        h[s] = data[i]
      end
    end

    ##
    # Given a set of surveys, determines whether the survey is cached.  If it
    # is, maps the survey to true; otherwise, maps the survey to false.
    #
    # This saves bandwidth over #get when you don't care about the survey
    # contents, just that something exists for a survey key.  (It's assumed
    # that if a key exists, it's going to point to a survey.)
    #
    # Unlike #get, this is suspectible to edge conditions on key expiration,
    # but for most use cases it's good enough.
    def peek(surveys)
      exists = redis.pipelined do
        keys_for(surveys).each { |k| redis.exists(k) }
      end

      surveys.each.with_object({}).with_index do |(s, h), i|
        h[s] = exists[i]
      end
    end

    ##
    # Removes cached data for the given surveys.  This method may be called
    # for any set of surveys, even if those surveys have not been cached.
    #
    # @return void
    def delete(surveys)
      return if surveys.empty?

      redis.del keys_for(surveys)
    end

    ##
    # Generates JSON for the given surveys and adds it to the cache.
    #
    # @return void
    def put(surveys)
      return if surveys.empty?

      keys = keys_for(surveys)
      data = keys.zip(surveys.map(&:to_json))

      redis.pipelined do
        redis.mset(*data)
        set_expiration(keys)
      end
    end

    ##
    # Returns the TTLs of a set of surveys.  If a survey isn't cached or has
    # expired, returns -1 in its place.
    #
    # The TTLs are returned in the same order as the input list.
    #
    # Intended for testing.
    def ttl(surveys)
      keys_for(surveys).map { |k| redis.ttl(k) }
    end

    ##
    # Extends the cache lifetime of the given surveys to now + TTL.
    def renew(surveys)
      redis.pipelined { set_expiration(keys_for(surveys)) }
    end

    ##
    # Redis key namespace.
    def survey_cache_namespace
      "nubic:ncs_navigator_core:survey_cache"
    end

    def set_expiration(keys)
      at = Time.now.to_i + TTL

      keys.each { |k| redis.expireat(k, at) }
    end

    def keys_for(surveys)
      surveys.map { |s| "#{survey_cache_namespace}:#{s.api_id}" }
    end
  end
end
