require 'sidekiq'
require 'ncs_navigator/core'

class WatchdogWorker
  include NcsNavigator::Core::WorkerWatchdog
  include NcsNavigator::Core::RedisConfiguration
  include Sidekiq::Worker

  def initialize
    establish_redis_connection
  end

  def perform
    redis.set(worker_watchdog_key, Time.now.to_i)
  end
end
