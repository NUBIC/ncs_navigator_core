# -*- coding: utf-8 -*-
require 'bcdatabase'
require 'erb'
require 'ncs_navigator/core'
require 'redis'
require 'yaml'

##
# Configuration for Cases' Redis instance.
#
# This module is used by Cases' scheduler and therefore MUST be usable without
# the Rails application environment loaded.  This means:
#
# * limited usage of the Rails module: .env, .root, and .logger is all you get
# * no dependencies on ActiveSupport's autoloading code
# * no direct or indirect references to configured ActiveRecord objects
module NcsNavigator::Core::RedisConfiguration
  attr_reader :redis

  def establish_redis_connection
    @redis = redis_connection
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

  private

  def redis_connection
    Rails.logger.info "Connecting to redis using #{redis_options.inspect}"
    Redis.new(redis_options)
  end

  def redis_configurations
    db_config = File.read(Rails.root.join("config/database.yml"))

    @redis_configurations ||= YAML.load(ERB.new(db_config).result(binding))
  end

  def default_redis_options
    redis_configurations["redis_#{Rails.env}"] or
      fail("No redis options for #{Rails.env} environment")
  end

  def redis_host
    redis_options[:host] || '127.0.0.1'
  end

  def redis_port
    redis_options[:port] || 6379
  end

  def redis_db
    redis_options[:db] || 0
  end
end

if defined?(Rails.application)
  Rails.application.send(:extend, NcsNavigator::Core::RedisConfiguration)
end
