require 'ncs_navigator/core'

module NcsNavigator::Core::RedisConfiguration
  def redis
    @redis ||= redis_connection
  end

  ##
  # While we use the redis options for Core's redis, sidekiq only
  # works with a URL.
  def redis_url
    "redis://#{redis_host}:#{redis_port}/#{redis_db}"
  end

  def redis_options
    # symbol keys are required by redis-rb
    @redis_options ||= default_redis_options.symbolize_keys
  end

  def redis_options=(opts)
    # symbol keys are required by redis-rb
    @redis_options = opts.symbolize_keys
  end

  def redis_connection
    Rails.logger.info "Connecting to redis using #{redis_options.inspect}"
    Redis.new(redis_options)
  end
  private :redis_connection

  def default_redis_options
    ActiveRecord::Base.configurations["redis_#{Rails.env}"] or
      fail("No redis options for #{Rails.env} environment")
  end
  private :default_redis_options

  def redis_host
    redis_options[:host] || '127.0.0.1'
  end
  private :redis_host

  def redis_port
    redis_options[:port] || 6379
  end
  private :redis_port

  def redis_db
    redis_options[:db] || 0
  end
  private :redis_db
end

Rails.application.send(:extend, NcsNavigator::Core::RedisConfiguration)
