require 'redis'

module DeferredRedisConnection
  def redis
    @redis ||= redis_connection
  end

  def redis_url
    begin
      @redis_url ||= config.redis_url
    rescue NoMethodError
      fail 'Please set config.redis_url for this environment'
    end
  end
  private :redis_url

  def redis_connection
    Rails.logger.info "Connecting to #{redis_url}"
    Redis.connect(:url => redis_url)
  end
  private :redis_connection
end

Rails.application.send(:extend, DeferredRedisConnection)
