require 'sidekiq'

class SurveyCacheWorker
  include Sidekiq::Worker

  def self.period
    1800.seconds
  end

  def perform
    Survey.cache_recent
  end
end
