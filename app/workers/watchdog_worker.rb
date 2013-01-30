require 'sidekiq'
require 'ncs_navigator/core'

class WatchdogWorker
  extend NcsNavigator::Core::WorkerWatchdog
  include NcsNavigator::Core::RedisConfiguration
  include Sidekiq::Worker

  def self.period
    watchdog_periodicity
  end

  def initialize
    establish_redis_connection
  end

  def perform
    redis.set(self.class.worker_watchdog_key, Time.now.to_i)
  end
end
