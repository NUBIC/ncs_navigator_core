# This is the Clockwork configuration file for a Cases instance.
#
# While you MAY refer to Cases application libraries in this file, you SHOULD
# NOT load any files that require the Rails application environment to be
# loaded.

# Make libraries and workers available.
$LOAD_PATH.unshift(File.expand_path('../../app/workers', __FILE__))
$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))

require 'clockwork'
require 'ncs_navigator/core'
require 'pathname'

require 'survey_cache_worker'
require 'watchdog_worker'

LOG = Logger.new($stderr)

# The bare necessities.
module Rails
  module_function

  def env
    (ENV['RAILS_ENV'] || 'development').downcase
  end

  def root
    Pathname.new(File.expand_path('../..', __FILE__))
  end

  def logger
    LOG
  end
end

include Clockwork
include NcsNavigator::Core::SidekiqConfiguration

handler { |job| job.perform_async }
sidekiq_configure_client

[
  SurveyCacheWorker,
  WatchdogWorker
].each do |worker|
  every(worker.period.seconds, worker)
end
