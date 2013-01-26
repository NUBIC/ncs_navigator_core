# -*- coding: utf-8 -*-

require 'ncs_navigator/core'

module NcsNavigator::Core
  module SidekiqConfiguration
    include RedisConfiguration

    def sidekiq_namespace
      'nubic:ncs_navigator_core:sidekiq'
    end

    def sidekiq_configure_client
      Sidekiq.configure_client do |config|
        config.redis = { :url => redis_url, :namespace => sidekiq_namespace, :size => 1 }
      end
    end

    def sidekiq_configure_server
      Sidekiq.configure_server do |config|
        config.redis = { :url => redis_url, :namespace => sidekiq_namespace }
      end
    end

    def sidekiq_configure_all
      sidekiq_configure_client
      sidekiq_configure_server
    end
  end
end

if defined?(Rails.application)
  Rails.application.send(:extend, NcsNavigator::Core::SidekiqConfiguration)
end
